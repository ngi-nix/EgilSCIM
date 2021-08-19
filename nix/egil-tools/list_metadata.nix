{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
}:
pkgs:


with pkgs;
import ./default.nix {
  inherit version;

  filename = "list_metadata.py";

  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      url-normalize
    ]))
  ];

  meta = {
    description = "List contents in authentication metadata";
    longDescription = "A script for listing entities from the metadata.";

    inherit homepage downloadPage changelog;

    license = lib.licenses.mit;
    inherit maintainers platforms;
  };
} pkgs
