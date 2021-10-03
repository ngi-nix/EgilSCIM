{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
, source
}:
{ lib
, python3
, pythonPackages
, ...
}@pkgs:

import ./default.nix
{
  inherit version source;

  filename = "list_metadata.py";

  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      url-normalize.out
    ]))
  ];

  meta = {
    description = "List contents in authentication metadata";
    longDescription = "A script for listing entities from the metadata.";

    inherit homepage downloadPage changelog;

    license = lib.licenses.mit;
    inherit maintainers platforms;
  };
}
  pkgs
