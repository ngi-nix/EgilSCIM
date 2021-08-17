{ version
, homepage
, maintainers
, platforms
}:
pkgs:


with pkgs;
import ./default.nix {
  inherit version;

  filename = "fetch_metadata.py";

  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      python-jose
    ]))
  ];

  meta = {
    inherit homepage maintainers platforms;

    description = "Download and verify federated TLS authentication metadata";
    longDescription =
      "The script fetch_metadata.py will both download and verify the " +
      "authentication metadata against a key. The decoded metadata can " +
      "then be used by the EGIL client in order to connect to and " +
      "authenticate a server.";
    license = lib.licenses.mit;
  };
} pkgs
