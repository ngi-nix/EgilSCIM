{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
, isDebugBuild ? false
, doCheck ? true
}:
pkgs:

with pkgs;
let
  inherit (lib) optionalString optionals filter cleanSourceWith hasPrefix removePrefix;

  src = ./..;
  packageName = "egil-scim-client";
  exeName = "EgilSCIMClient";

  suffix = optionalString isDebugBuild "-debug";
  pname = "${packageName}${suffix}";
  exePath = "/bin/${exeName}${suffix}";

  sourceFilter = name: type: let
    baseName = baseNameOf (toString name);
    sansPrefix = removePrefix (toString src) name;
  in (
    baseName == "CMakeLists.txt" ||
    hasPrefix "/src" sansPrefix
  );
in
stdenv.mkDerivation {
  inherit pname version;

  src = cleanSourceWith { inherit src; filter = sourceFilter; name = packageName; };

  strictDeps = true;

  dontPatch = true;

  buildInputs = [
    boost
    curl # libcurl
    openldap # libldap
  ];

  nativeBuildInputs = [
    cmake
  ];

  dontStrip = isDebugBuild;

  cmakeFlags = [
    (optionalString isDebugBuild "-DCMAKE_BUILD_TYPE=Debug")
  ];

  installPhase = ''
    mkdir -p $out/bin/
    cp ${exeName} $out${exePath}
  '';

  inherit doCheck;

  checkPhase = ''
    ./tests
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
    inherit maintainers platforms;
  };

  passthru = {
    inherit exePath;
  };
}
