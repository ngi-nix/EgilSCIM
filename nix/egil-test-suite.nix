{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
, source
}:
{ lib
, bash
, docker
, dockerTools
, egil-scim-client
, egil-test-server
, makeWrapper
, openssl
, stdenvNoCC
, writeShellScript
, ...
}:

let
  inherit (lib) makeSearchPath;
  inherit (dockerTools) pullImage;

  pname = "egil-test-suite";
  mainProgram = "run_test_suite";

  buildInputs = [
    bash.out
    docker.out
    egil-scim-client.bin
    egil-test-server.out
    openssl.bin
  ];
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  src = "${toString source}/test";

  strictDeps = true;

  inherit buildInputs;
  nativeBuildInputs = [
    makeWrapper
  ];

  patchPhase = ''
    substituteInPlace ./scripts/run_test_suite \
      --replace "\''${testroot}/test_server_go/EGILTestServer/" "" \
      --replace "\''${testroot}/../build/" ""
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    cp -r . $out

    mkdir $out/bin/
    ln -s $out/scripts/run_test_suite $out/bin/${mainProgram}
  '';

  postFixup = ''
    for file in $out/scripts/*; do
      [ -f "$file" ] && [ -x "$file" ] || continue
      wrapProgram "$file" --prefix PATH : "${makeSearchPath "bin" buildInputs}"
    done
  '';

  passthru =
    let
      dockerImages = [
        (pullImage {
          imageName = "osixia/openldap";
          imageDigest = "sha256:d212a12aa728ccb4baf06fcc83dc77392d90018d13c9b40717cf455e09aeeef3";
          sha256 = "sha256-91CSC1kVGgMB7ZRoiuLjn5YpBZIgcZDcmJzwQNJYg/U=";
          os = "linux";
          arch = "amd64";
          finalImageTag = "1.2.4";
        })
      ];

      loadDockerImages = writeShellScript "load-docker-images.sh" ''
        for image in ${toString dockerImages}; do
          [ -f "$image" ] || continue
          docker load --input=$image
        done
      '';
    in
    {
      inherit loadDockerImages;
    };

  meta = {
    description = "The EGIL test suite";
    longDescription =
      "The system test suite includes an LDAP server and a way to " +
      "automatically populate it with example students, groups, teachers, " +
      "school units etc. There's also a simple system for running scenarios " +
      "(\"Student X is deleted\"). This might be of interest also for those " +
      "that want to test their server implementations.";

    inherit homepage downloadPage changelog;

    license = null;
    inherit maintainers mainProgram platforms;
  };
}
