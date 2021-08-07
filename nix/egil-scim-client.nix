{ supportedSystems
, debugBuild ? false
}:
nixpkgs:

let
  suffix = nixpkgs.lib.optionalString debugBuild "-debug";
  programName = "EgilSCIMClient${suffix}";
  exePath = "/bin/${programName}";
in
with nixpkgs; stdenv.mkDerivation rec {
  pname = "egil-scim-client${suffix}";
  version = "2.7.0";
  src = ./..;

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
    (lib.optionalString debugBuild "-DCMAKE_BUILD_TYPE=Debug")
  ];

  installPhase = ''
    mkdir -p $out/bin/
    cp EgilSCIMClient $out${exePath}
  '';

  meta = with lib; {
    description = "The EGIL SCIM client" +
      optionalString debugBuild " - debug build";
    longDescription =
      "The EGIL SCIM client implements the EGIL profile of the SS 12000 " +
      "standard. It reads information about students, groups etc. from LDAP " +
      "and sends updates to a SCIM server.";
    homepage = "https://www.skolfederation.se/egil-scimclient-esc/";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = supportedSystems;
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
