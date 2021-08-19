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
stdenvNoCC.mkDerivation {
  pname = "egil-tools-${toolName}";
  inherit version;

  src = ./../../tools + "/${filename}";

  strictDeps = true;

  inherit buildInputs;

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out${exePath}
  '';

  passthru = {
    inherit exePath;
  };

  inherit meta;
}
