{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
}:
{ bash
, openssl
, ...
}@pkgs:

import ./default.nix
{
  inherit version;

  filename = "public_key_pin.sh";

  buildInputs = [
    bash.out
    openssl.bin
  ];

  meta = {
    description =
      "A script for generating a public key pin based on an x509 certificate";
    longDescription =
      "Extracts public key from a x509 certificate and outputs its pin. " +
      "Depends on OpenSSL.";

    inherit homepage downloadPage changelog;

    license = null;
    inherit maintainers platforms;
  };

  wrapProgram = true;
}
  pkgs
