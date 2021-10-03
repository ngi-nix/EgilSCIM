{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
, source
, isDebugBuild ? false
, doCheck ? true
}:
{ lib
, boost
, cmake
, curl
, openldap
, stdenv
, ...
}:

let
  inherit (lib)
    optionalString
    optionals
  ;

  packageName = "egil-scim-client";
  exeName = "EgilSCIMClient";
  suffix = optionalString isDebugBuild "-debug";
  pname = "${packageName}${suffix}";
  mainProgram = "${exeName}${suffix}";
in
stdenv.mkDerivation {
  inherit pname version;

  src = source;

  outputs = [ "bin" "dev" "out" ];
  propagatedBuildOutputs = [ ];

  strictDeps = true;

  buildInputs = [
    boost.dev
    curl.dev # libcurl
    openldap.dev # libldap
  ];

  nativeBuildInputs = [
    cmake.out
  ];

  dontPatch = true;

  cmakeFlags = [
    (optionalString isDebugBuild "-DCMAKE_BUILD_TYPE=Debug")
  ];

  inherit doCheck;
  checkPhase = ''
    ./tests
  '';

  installPhase = ''
    mkdir -p $bin/bin/
    cp ${exeName} $bin/bin/${mainProgram}

    mkdir -p $dev/include/
    cp ../src/pp_interface.h $dev/include/

    mkdir $out
  '';

  dontStrip = isDebugBuild;

  doInstallCheck = true;
  installCheckPhase = ''
    $bin/bin/${mainProgram} --version
  '';

  meta = {
    description = "The EGIL SCIM client" +
      optionalString isDebugBuild " - debug build";
    longDescription =
      "The EGIL SCIM client implements the EGIL profile of the SS 12000 " +
      "standard. It reads information about students, groups etc. from LDAP " +
      "and sends updates to a SCIM server.";

    inherit homepage downloadPage changelog;

    license = lib.licenses.agpl3Plus;
    inherit maintainers mainProgram platforms;
  };
}
