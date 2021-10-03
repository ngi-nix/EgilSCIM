{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
, source
}:
{ lib
, buildGoModule
, ...
}:

let
  mainProgram = "EGILTestServer";
in
buildGoModule {
  pname = "egil-test-server";
  inherit version;
  src = "${toString source}/test/test_server_go/${mainProgram}";

  vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";

  dontPatch = true;

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/${mainProgram} --help
  '';

  meta = {
    description = "Test server for EgilSCIM";
    longDescription =
      "A simple server using openssl with the purpose of testing the " +
      "current set up of EgilSCIM. It is not a complete SCIM server, it " +
      "simply receives and logs the requests done by the client and returns " +
      "successful status codes back so the client thinks everything is " +
      "accepted";

    inherit homepage downloadPage changelog;

    license = lib.licenses.agpl3Plus;
    inherit maintainers mainProgram platforms;
  };
}
