{ version
, homepage
, maintainers
, platforms
}:
nixpkgs:

with nixpkgs;
buildGoModule rec {
  pname = "egil-test-server";
  inherit version;

  src = ./../test/test_server_go/EGILTestServer;

  vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";

  meta = {
    inherit homepage maintainers platforms;

    description = "Test server for EgilSCIM";
    longDescription =
      "A simple server using openssl with the purpose of testing the " +
      "current set up of EgilSCIM. It is not a complete SCIM server, it " +
      "simply receives and logs the requests done by the client and returns " +
      "successful status codes back so the client thinks everything is " +
      "accepted";
    license = lib.licenses.agpl3Plus;
  };
}
