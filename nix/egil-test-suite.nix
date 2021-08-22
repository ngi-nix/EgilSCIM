{ version
, homepage
, downloadPage
, changelog
, maintainers
, platforms
}:
pkgs:

with pkgs;
let
  inherit (builtins) any;
  inherit (lib) cleanSourceWith hasPrefix removePrefix makeSearchPath;

  src = ./../test;
  pname = "egil-test-suite";
  exePath = "/bin/run_test_suite";

  sourceFilter = name: type: let
    relativePath = removePrefix (toString src) name;
  in (
    any (directory: hasPrefix directory relativePath) [
      "/configs"
      "/scenarios"
      "/scripts"
      "/tests"
    ]
  );

  buildInputs = [
    bash.out
    docker.out
    egil-scim-client
    egil-test-server
    openssl.bin
  ];

  executableSearchPath = makeSearchPath "bin" buildInputs;
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  src = cleanSourceWith { inherit src; filter = sourceFilter; name = pname; };

  strictDeps = true;

  inherit buildInputs;
  nativeBuildInputs = [
    makeWrapper
  ];

  patchPhase = ''
    ls -al;
    substituteInPlace ./scripts/run_test_suite \
      --replace "\''${testroot}/test_server_go/EGILTestServer/" "" \
      --replace "\''${testroot}/../build/" ""
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    cp -r . $out
    mkdir $out/bin/
    ln -s $out/scripts/run_test_suite $out${exePath}
  '';

  postFixup = ''
    for file in $out/scripts/*; do
      [ -f "$file" ] && [ -x "$file" ] || continue
      wrapProgram "$file" --prefix PATH : "${executableSearchPath}"
    done
  '';

  passthru = {
    inherit exePath;
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
    inherit maintainers platforms;
  };
}
