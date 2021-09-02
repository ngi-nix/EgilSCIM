{
  description = "The EGIL SCIM client";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    nix-utils = {
      url = "git+https://git.sr.ht/~ilkecan/nix-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nix-utils, ... }@inputs:
    let
      inherit (builtins)
        attrNames
        attrValues
        filter
        substring
      ;
      inherit (flake-utils.lib)
        defaultSystems
        eachSystem
      ;
      inherit (nixpkgs.lib)
        getAttrs
        getBin
        hasPrefix
        hasSuffix
        intersectLists
        optionalAttrs
        optionals
        subtractLists
      ;
      nix-filter = inputs.nix-filter.lib;
      inherit (nix-utils.lib)
        createOverlays
        getUnstableVersion
        createDebugSymbolsSearchPath
      ;

      supportedSystems = defaultSystems;
      commonArgs = {
        version = getUnstableVersion self.lastModifiedDate;
        homepage = "https://www.skolfederation.se/egil-scimclient-esc/";
        downloadPage = "https://github.com/Sambruk/EgilSCIM/releases";
        changelog = "https://raw.githubusercontent.com/Sambruk/EgilSCIM/master/CHANGELOG.md";
        maintainers = [
          {
            name = "ilkecan bozdogan";
            email = "ilkecan@protonmail.com";
            github = "ilkecan";
            githubId = "40234257";
          }
        ];
        platforms = supportedSystems;
      };

      derivations = {
        egil-scim-client = import ./nix/egil-scim-client.nix commonArgs;
        egil-scim-client-debug = import ./nix/egil-scim-client.nix (commonArgs // { isDebugBuild = true; });

        egil-plugins-echo = import ./nix/egil-plugins-echo.nix commonArgs;

        egil-test-server = import ./nix/egil-test-server.nix commonArgs;
        egil-test-suite = import ./nix/egil-test-suite.nix commonArgs;

        egil-tools = import ./nix/egil-tools/all.nix (commonArgs // { inherit egilToolPackageNames; });
        egil-tools-fetch_metadata = import ./nix/egil-tools/fetch_metadata.nix commonArgs;
        egil-tools-list_metadata = import ./nix/egil-tools/list_metadata.nix commonArgs;
        egil-tools-public_key_pin = import ./nix/egil-tools/public_key_pin.nix commonArgs;
      };

      packageNames = attrNames derivations;
      egilToolPackageNames = filter (hasPrefix "egil-tools-") packageNames;
      debugPackageNames = filter (hasSuffix "-debug") packageNames;
      nonDebugPackageNames = subtractLists debugPackageNames packageNames;
    in
    {
      overlays = createOverlays derivations { inherit nix-filter; };
      overlay = self.overlays.egil-scim-client;
    } // eachSystem supportedSystems (system:
      let
        inherit (pkgs.stdenv) isLinux;

        packageNamesToSkip = optionals (system != "x86_64-linux") [ "egil-test-suite" ];
        packageNamesToKeep = subtractLists packageNamesToSkip packageNames;

        overlays = getAttrs packageNamesToKeep self.overlays;
        pkgs = import nixpkgs {
          inherit system;
          overlays = attrValues overlays;
        };
      in
      rec {
        checks = packages;

        packages = getAttrs packageNamesToKeep pkgs;
        defaultPackage = packages.egil-scim-client;

        hydraJobs = {
          build = getAttrs (intersectLists packageNamesToKeep nonDebugPackageNames) packages;

          vmTest = optionalAttrs isLinux {
            egil-test-suite = optionalAttrs (system == "x86_64-linux") (import "${nixpkgs}/nixos/tests/make-test-python.nix"
              ({ ... }: {
                name = "egil-test-suite";

                machine = { ... }: {
                  environment.systemPackages = with pkgs; [
                    egil-test-suite
                  ];

                  virtualisation.docker.enable = true;
                  virtualisation.diskSize = 1024; # 512 is not enough
                };

                testScript = with pkgs; ''
                  machine.wait_for_unit("docker.service")
                  machine.execute("${egil-test-suite.loadDockerImages.out}")
                  machine.succeed("run_test_suite")
                '';
              })
              { inherit system pkgs; });
          };
        };

        devShell =
          let
            inherit (pkgs) mkShell egil-scim-client-debug;
            inherit (pkgs.stdenv) glibc;

            debugPackages = attrValues (getAttrs debugPackageNames packages);
          in
          mkShell {
            packages = with pkgs; [
              gdb.out
            ] ++ optionals (system == "x86_64-linux") [ egil-test-suite.out ]
            ++ map getBin debugPackages;

            inputsFrom = debugPackages;

            shellHook = ''
              export NIX_DEBUG_INFO_DIRS=${createDebugSymbolsSearchPath pkgs debugPackages}
              alias gdb='gdb --directory=${egil-scim-client-debug.source}'
            '';
          };
      });
}
