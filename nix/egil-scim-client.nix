{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
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
  inherit (lib) optionalString optionals filter cleanSourceWith hasPrefix removePrefix;

  src = ./..;
  packageName = "egil-scim-client";
  exeName = "EgilSCIMClient";

  suffix = optionalString isDebugBuild "-debug";
  pname = "${packageName}${suffix}";
  exePath = "/bin/${exeName}${suffix}";

  sourceFilter = name: type:
    let
      baseName = baseNameOf (toString name);
      relativePath = removePrefix (toString src) name;
    in
    (
      baseName == "CMakeLists.txt" ||
      hasPrefix "/src" relativePath
    );
in
stdenv.mkDerivation {
  inherit pname version;

  src = cleanSourceWith { inherit src; filter = sourceFilter; name = packageName; };

  outputs = [ "bin" "dev" ] ++ optionals isDebugBuild [ "source" ] ++ [ "out" ];
  propagatedBuildOutputs = [ ];

  strictDeps = true;

  buildInputs = [
    boost.dev
    curl.dev # libcurl
    openldap.dev # libldap
  ];

  nativeBuildInputs = [
    cmake
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
    cp ${exeName} $bin${exePath}

    mkdir -p $dev/include/
    cp ../src/pp_interface.h $dev/include/

    mkdir $out
  '' + optionalString isDebugBuild ''
    cp -r ../src $source
  '';

  dontStrip = isDebugBuild;

  passthru = {
    inherit exePath;
  };

  meta = {
    description = "The EGIL SCIM client" +
      optionalString isDebugBuild " - debug build";
    longDescription =
      "The EGIL SCIM client implements the EGIL profile of the SS 12000 " +
      "standard. It reads information about students, groups etc. from LDAP " +
      "and sends updates to a SCIM server.";

    inherit homepage downloadPage changelog;

    license = lib.licenses.agpl3Plus;
    inherit maintainers platforms;
  };
}
