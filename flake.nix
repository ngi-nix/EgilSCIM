{
  description = "The EGIL SCIM client";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (builtins) mapAttrs listToAttrs attrValues attrNames concatStringsSep filter;
      inherit (flake-utils.lib) defaultSystems eachSystem mkApp;
      inherit (nixpkgs.lib) hasPrefix hasSuffix getAttrs subtractLists catAttrs unique flatten optional;

      supportedSystems = defaultSystems;
      commonArgs = {
        version = "2.7.0";
        homepage = "https://www.skolfederation.se/egil-scimclient-esc/";
        maintainers = [];
        platforms = supportedSystems;
      };

      derivations = {
        egil-scim-client = import ./nix/egil-scim-client.nix commonArgs;
        egil-scim-client-debug = import ./nix/egil-scim-client.nix (commonArgs // { isDebugBuild = true; });
        egil-test-server = import ./nix/egil-test-server.nix commonArgs;
        egil-tools-fetch_metadata = import ./nix/egil-tools/fetch_metadata.nix commonArgs;
        egil-tools-list_metadata = import ./nix/egil-tools/list_metadata.nix commonArgs;
        egil-tools-public_key_pin = import ./nix/egil-tools/public_key_pin.nix commonArgs;
      };

      packageNames = attrNames derivations;
      debugPackageNames = filter (hasSuffix "-debug") packageNames;
    in
    {
      overlays = mapAttrs
        (name: drv:
          (final: prev:
            listToAttrs [
              { name = name; value = drv prev; }
            ]
          )
        )
        derivations;

      overlay = self.overlays.egil-scim-client;
    } // eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = attrValues self.overlays;
        };
      in
      rec {
        checks = packages;

        packages = getAttrs packageNames pkgs;

        defaultPackage = pkgs.egil-scim-client;

        apps = mapAttrs (name: app: mkApp { drv = app; }) packages;

        defaultApp = apps.egil-scim-client;

        hydraJobs = {
          build = getAttrs (subtractLists debugPackageNames packageNames) packages;
        };

        devShell = pkgs.mkShell {
          packages = with pkgs; [
            gdb
          ];

          shellHook =
            let
              debugPackages = attrValues (getAttrs debugPackageNames packages);
              # TODO recursively look into child dependencies
              debugInputs = unique (flatten (catAttrs "buildInputs" debugPackages));
              hasDebugInfo = drv: drv ? separateDebugInfo && drv.separateDebugInfo;
              debugInfoDirs = map (drv: drv.debug + "/lib/debug") (filter hasDebugInfo debugInputs);
            in
            ''
              export NIX_DEBUG_INFO_DIRS=${concatStringsSep ":" debugInfoDirs}
              alias gdb='gdb --directory=./src/'
            '';

          inputsFrom = attrValues packages;
        };
      });
}
