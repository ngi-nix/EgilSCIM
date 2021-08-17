{ version
, homepage
, maintainers
, platforms
}:
nixpkgs:

with nixpkgs;
let
  inherit (builtins) replaceStrings;

  toolName = "list-metadata";
  filename = replaceStrings [ "-" ] [ "_" ] toolName + ".py";
  exePath = "/bin/${filename}";
in
stdenv.mkDerivation rec {
  pname = "egil-tools-${toolName}";
  inherit version;

  strictDeps = true;

  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [
      url-normalize
    ]))
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${./../tools + "/${filename}"} $out${exePath}
  '';

  meta = {
    inherit homepage maintainers platforms;

    description = "List contents in authentication metadata";
    longDescription = "A script for listing entities from the metadata.";
    license = lib.licenses.mit;
  };

  passthru = {
    inherit exePath;
  };
}
