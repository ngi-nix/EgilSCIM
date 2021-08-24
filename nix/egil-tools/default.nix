{ filename
, version
, buildInputs
, meta
, wrapProgram ? false
}:
{ lib
, makeWrapper
, stdenvNoCC
, ...
}:

let
  inherit (builtins) replaceStrings split elemAt;
  inherit (lib) optional optionalString makeSearchPath;

  toolName = elemAt (split "\\." filename) 0;
  exePath = "/bin/${filename}";
in
stdenvNoCC.mkDerivation {
  pname = "egil-tools-${toolName}";
  inherit version;
  src = ./../../tools + "/${filename}";

  strictDeps = true;

  inherit buildInputs;
  nativeBuildInputs = optional wrapProgram makeWrapper;

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out${exePath}
  '';

  postFixup = optionalString wrapProgram ''
    wrapProgram $out${exePath} --prefix PATH : "${makeSearchPath "bin" buildInputs}"
  '';

  passthru = {
    inherit exePath;
  };

  inherit meta;
}
