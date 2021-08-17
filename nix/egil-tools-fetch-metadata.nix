{ version
, homepage
, maintainers
, platforms
}:
nixpkgs:

with nixpkgs;
let
  inherit (builtins) replaceStrings;

  toolName = "fetch-metadata";
  filename = replaceStrings [ "-" ] [ "_" ] toolName + ".py";
  exePath = "/bin/${filename}";
in
stdenv.mkDerivation rec {
  pname = "egil-tools-${toolName}";
  inherit version;

  strictDeps = true;

  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      python-jose
    ]))
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${./../tools + "/${filename}"} $out${exePath}
  '';

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

  passthru = {
    inherit exePath;
  };
}
