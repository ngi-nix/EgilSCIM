{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
, source
}:
{ lib
, egil-scim-client
, stdenv
, ...
}:

stdenv.mkDerivation {
  pname = "egil-plugins-echo";
  inherit version;

  src = "${toString source}/plugins/pp/echo";

  outputs = [ "lib" "out" ];
  propagatedBuildOutputs = [ ];

  strictDeps = true;

  buildInputs = [
    egil-scim-client.dev
  ];

  dontPatch = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $lib/lib/
    cp libecho.so $lib/lib/

    mkdir $out
  '';

  meta = {
    description = "An example plugin for EgilSCIM";
    longDescription =
      "An example plugin which simply copies the input text without making " +
      "any real post processing changes.";
    inherit homepage downloadPage changelog;

    license = lib.licenses.agpl3Plus;
    inherit maintainers platforms;
  };
}
