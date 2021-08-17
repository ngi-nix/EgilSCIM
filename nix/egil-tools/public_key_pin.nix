{ version
, homepage
, maintainers
, platforms
}:
pkgs:


with pkgs;
import ./default.nix {
  inherit version;

  filename = "public_key_pin.sh";

  buildInputs = [
    bash.out
    curl.bin
  ];

  meta = {
    inherit homepage maintainers platforms;

    description =
      "A script for generating a public key pin based on an x509 certificate";
    longDescription =
      "Extracts public key from a x509 certificate and outputs its pin. " +
      "Depends on OpenSSL.";
    license = null;
  };
} pkgs
