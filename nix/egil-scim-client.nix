{ version
, homepage
, maintainers
, platforms
, isDebugBuild ? false
, doCheck ? true
}:
pkgs:

with pkgs;
let
  inherit (lib) optionalString optionals filter cleanSourceWith hasPrefix;

  baseName = "EgilSCIMClient";
  suffix = optionalString isDebugBuild "-debug";
  programName = "${baseName}${suffix}";
  exePath = "/bin/${programName}";
  sourceFilter = name: type: let
    baseName = baseNameOf (toString name);
    sansPrefix = lib.removePrefix (toString ./..) name;
  in (
    baseName == "CMakeLists.txt" ||
    hasPrefix "/src" sansPrefix
  );
in
stdenv.mkDerivation rec {
  pname = "egil-scim-client${suffix}";
  inherit version;

  src = cleanSourceWith { filter = sourceFilter; src = ./..; name = baseName; };

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
    cp ${baseName} $out${exePath}
  '';

  inherit doCheck;

  checkPhase = ''
    ./tests
  '';

  meta = {
    inherit homepage maintainers platforms;

    description = "The EGIL SCIM client" +
      optionalString isDebugBuild " - debug build";
    longDescription =
      "The EGIL SCIM client implements the EGIL profile of the SS 12000 " +
      "standard. It reads information about students, groups etc. from LDAP " +
      "and sends updates to a SCIM server.";
    license = lib.licenses.agpl3Plus;
  };

  passthru = {
    inherit exePath;
  };
}
