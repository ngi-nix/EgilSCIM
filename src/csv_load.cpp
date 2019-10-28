/**
 *  This file is part of the EGIL SCIM client.
 *
 *  Copyright (C) 2017-2019 Föreningen Sambruk
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Affero General Public License for more details.

 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "csv_load.hpp"
#include "config_file.hpp"
#include "load_limiter.hpp"
#include "data_server.hpp"

// Constructs a base_object from a CSV record
std::shared_ptr<base_object> csv_entry_to_base_object(const string_vector& values,
                                                      const string_vector& attribute_names,
                                                      const std::string& type) {
    attrib_map attributes;

    for (size_t i = 0; i < values.size(); ++i) {
        attributes[attribute_names[i]] = string_vector({values[i]});
    }

    attributes["ss12000type"] = string_vector({type});
    return std::make_shared<base_object>(std::move(attributes));
}

// Goes through all records in a CSV file and creates base_objects 
std::shared_ptr<object_list> csv_to_object_list(std::shared_ptr<csv_file> file,
                                                const std::string& type,
                                                std::shared_ptr<load_limiter> limiter,
                                                indented_logger& load_logger) {
    auto objects =  std::make_shared<object_list>();
    const auto attribute_names = file->get_header();
    
    for (size_t i = 0; i < file->size(); ++i) {
        auto object = csv_entry_to_base_object((*file)[i], attribute_names, type);

        auto uid = object->get_uid();
        if (!uid.empty() && limiter->include(object.get())) {
            objects->add_object(uid, object);

            load_logger.log("Found " + type + " " + uid);
        }
    }

    return objects;
}

// Adds multi values attributes to a list of objects.
//
// The file contains values for one multi-valued attribute.
void add_multi_valued(std::shared_ptr<csv_file> file,
                      std::shared_ptr<object_list>& objects) {
    auto header = file->get_header();

    // We expect exactly 2 columns, a key to the main table and
    // a column of values. The header for the first column will
    // determine which attribute in the main table to use for key.
    // The header for the second column will determine what the
    // multi valued attribute will be named.
    if (header.size() != 2) {
        throw std::runtime_error("expected exactly two columns in CSV file with multi valued attributes");
    }
    
    auto key = header[0];
    auto attribute = header[1];

    // Create an index on key
    std::map<std::string, std::shared_ptr<base_object>> index;

    for (auto& iter : *objects) {
        index[iter.second->get_values(key)[0]] = iter.second;
    }

    for (size_t i = 0; i < file->size(); ++i) {
        auto row = (*file)[i];

        if (index.find(row[0]) == index.end()) {
            // TODO: Should we give a warning or something?
            continue;
        }

        index[row[0]]->append_values(attribute, {row[1]});
    }
}

void load_related(const std::string &type,
                  const std::shared_ptr<object_list> &objects,
                  indented_logger& load_logger);

std::shared_ptr<object_list> csv_get(const std::string &type,
                                     indented_logger& load_logger) {
    load_logger.log(std::string("Loading entries for type ") + type + " from CSV");
    indented_logger::indenter indenter(load_logger);
    
    std::shared_ptr<object_list> objects;

    auto csv_files = config_file::instance().get_paths(type + "-csv-files");

    if (csv_files.empty()) {
        throw std::runtime_error("Expected at least one file in " + type + "-csv-files");
    }

    auto main_file = csv_files[0];

    // Create objects from main_file
    auto limiter = get_limiter(type);
    auto csv_store = data_server::instance().get_csv_store();
    objects = csv_to_object_list(csv_store->get_file(main_file),
                                 type, limiter, load_logger);

    // Get the multi-valued attributes
    for (size_t i = 1; i < csv_files.size(); ++i) {
        try {
            add_multi_valued(csv_store->get_file(csv_files[i]), objects);
        } catch (const std::runtime_error& e) {
            throw std::runtime_error(type + " : " + e.what());
        }
    }

    load_related(type, objects, load_logger);
    
    return objects;    
}
