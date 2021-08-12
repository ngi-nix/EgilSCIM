{ supportedSystems
, version
}:
nixpkgs:

with nixpkgs;
buildGoModule rec {
  pname = "egil-test-server";
  inherit version;

  src = ./../test/test_server_go/EGILTestServer;

  vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";

  meta =
    let
      inherit (lib) licenses maintainers;
    in
    {
      description = "Test server for EgilSCIM";
      longDescription =
        "A simple server using openssl with the purpose of testing the " +
        "current set up of EgilSCIM. It is not a complete SCIM server, it " +
        "simply receives and logs the requests done by the client and returns " +
        "successful status codes back so the client thinks everything is " +
        "accepted";
      homepage = "https://www.skolfederation.se/egil-scimclient-esc/";
      license = licenses.agpl3Plus;
      maintainers = with maintainers; [  ];
      platforms = supportedSystems;
    };
}
