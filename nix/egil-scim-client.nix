{ version
, homepage
, maintainers
, platforms
, debugBuild ? false
, doCheck ? true
}:
nixpkgs:

with nixpkgs;
let
  inherit (lib) optionalString optionals filter cleanSourceWith hasPrefix;

  baseName = "EgilSCIMClient";
  suffix = optionalString debugBuild "-debug";
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

  buildInputs = [
    boost
    curl # libcurl
    openldap # libldap
  ];

  nativeBuildInputs = [
    cmake
  ];

  dontStrip = debugBuild;

  cmakeFlags = [
    (optionalString debugBuild "-DCMAKE_BUILD_TYPE=Debug")
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
      optionalString debugBuild " - debug build";
    longDescription =
      "The EGIL SCIM client implements the EGIL profile of the SS 12000 " +
      "standard. It reads information about students, groups etc. from LDAP " +
      "and sends updates to a SCIM server.";
    license = lib.licenses.agpl3Plus;
  };

  passthru =
    let
      hasDebugInfo = drv: drv ? separateDebugInfo && drv.separateDebugInfo;
    in
    {
      inherit exePath;
      debugInfoFrom = optionals debugBuild (filter hasDebugInfo buildInputs);
    };
}
