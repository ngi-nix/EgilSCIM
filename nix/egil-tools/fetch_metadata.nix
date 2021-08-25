{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
}:
{ lib
, python3
, pythonPackages
, ...
}@pkgs:

import ./default.nix
{
  inherit version;

  filename = "fetch_metadata.py";

  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      python-jose.out
    ]))
  ];

  meta = {
    description = "Download and verify federated TLS authentication metadata";
    longDescription =
      "The script fetch_metadata.py will both download and verify the " +
      "authentication metadata against a key. The decoded metadata can " +
      "then be used by the EGIL client in order to connect to and " +
      "authenticate a server.";

    inherit homepage downloadPage changelog;

    license = lib.licenses.mit;
    inherit maintainers platforms;
  };
}
  pkgs
