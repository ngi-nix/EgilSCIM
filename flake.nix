{
  description = "The EGIL SCIM client";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (builtins) mapAttrs listToAttrs attrValues attrNames concatStringsSep;
      inherit (flake-utils.lib) defaultSystems eachSystem mkApp;

      supportedSystems = defaultSystems;
      commonArgs = {
        version = "2.7.0";
        homepage = "https://www.skolfederation.se/egil-scimclient-esc/";
        maintainers = [];
        platforms = supportedSystems;
      };
      derivations = {
        egil-scim-client = import ./nix/egil-scim-client.nix commonArgs;
        egil-scim-client-debug = import ./nix/egil-scim-client.nix (commonArgs // { debugBuild = true; });
        egil-test-server = import ./nix/egil-test-server.nix commonArgs;
        egil-tools-fetch-metadata = import ./nix/egil-tools-fetch-metadata.nix commonArgs;
        egil-tools-list-metadata = import ./nix/egil-tools-list-metadata.nix commonArgs;
        egil-tools-public-key-pin = import ./nix/egil-tools-public-key-pin.nix commonArgs;
      };
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
        inherit (pkgs.lib) getAttrs subtractLists catAttrs unique flatten optional;

        pkgs = import nixpkgs {
          inherit system;
          overlays = attrValues self.overlays;
        };
        packageNames = attrNames self.overlays;
      in
      rec {
        checks = packages;

        packages = getAttrs packageNames pkgs;

        defaultPackage = pkgs.egil-scim-client;

        apps = mapAttrs
          (name: app: mkApp { drv = app; })
          packages;

        defaultApp = apps.egil-scim-client;

        hydraJobs = {
          build = getAttrs
            (subtractLists [ "egil-scim-client-debug" ] packageNames)
            packages;
        };

        devShell = pkgs.mkShell {
          packages = with pkgs; [
            gdb
          ];

          shellHook =
            let
              # TODO recursively look into child dependencies
              debugInputs = unique (flatten (catAttrs "debugInfoFrom" (attrValues packages)));
              debugInfos = map (drv: drv.debug) debugInputs;
              debugInfoDirs = map (drv: drv + "/lib/debug") debugInfos;
            in
            ''
              export NIX_DEBUG_INFO_DIRS=${concatStringsSep ":" debugInfoDirs}
              alias gdb='gdb --directory=./src/'
            '';

          inputsFrom = attrValues packages;
        };
      });
}
