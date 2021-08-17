{ version
, homepage
, maintainers
, platforms
}:
nixpkgs:

with nixpkgs;
let
  inherit (builtins) replaceStrings;

  toolName = "public-key-pin";
  filename = replaceStrings [ "-" ] [ "_" ] toolName + ".sh";
  exePath = "/bin/${filename}";
in
stdenv.mkDerivation rec {
  pname = "egil-tools-${toolName}";
  inherit version;

  strictDeps = true;

  buildInputs = [
    curl.bin
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${./../tools + "/${filename}"} $out${exePath}
  '';

  meta =
    let
      inherit (lib) licenses maintainers;
    in
    {
      inherit homepage maintainers platforms;

      description =
        "A script for generating a public key pin based on an x509 certificate";
      longDescription =
        "Extracts public key from a x509 certificate and outputs its pin. " +
        "Depends on OpenSSL.";
      license = null;
    };

  passthru = {
    inherit exePath;
  };
}
