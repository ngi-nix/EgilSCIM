{ filename
, version
, buildInputs
, meta
}:
pkgs:

with pkgs;
let
  inherit (builtins) replaceStrings split elemAt;

  toolName = elemAt (split "\\." filename) 0;
  exePath = "/bin/${filename}";
in
stdenvNoCC.mkDerivation rec {
  inherit version buildInputs meta;

  pname = "egil-tools-${toolName}";

  strictDeps = true;

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${./../../tools + "/${filename}"} $out${exePath}
  '';

  passthru = {
    inherit exePath;
  };
}
