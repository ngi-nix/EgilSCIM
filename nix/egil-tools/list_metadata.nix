{ version
, homepage
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
    inherit homepage maintainers platforms;

    description = "List contents in authentication metadata";
    longDescription = "A script for listing entities from the metadata.";
    license = lib.licenses.mit;
  };
} pkgs
