{
  description = "The EGIL SCIM client";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      supportedSystems = flake-utils.lib.defaultSystems;
      commonArgs = { inherit supportedSystems; };
      derivations = {
        egil-scim-client = import ./nix/egil-scim-client.nix commonArgs;
        egil-scim-client-debug =
          import ./nix/egil-scim-client.nix (commonArgs // { debugBuild = true; });
      };
    in
    {
      overlays = builtins.mapAttrs
        (name: drv:
          (final: prev:
            builtins.listToAttrs [
              { name = name; value = drv prev; }
            ]
          )
        )
        derivations;

      overlay = self.overlays.egil-scim-client;
    } // flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = builtins.attrValues self.overlays;
        };
      in
      rec {
        checks = packages;

        packages = pkgs.lib.getAttrs (builtins.attrNames self.overlays) pkgs;

        defaultPackage = pkgs.egil-scim-client;

        apps = builtins.mapAttrs
          (name: app: flake-utils.lib.mkApp { drv = app; })
          packages;

        defaultApp = apps.egil-scim-client;

        hydraJobs = {
          build = { inherit (packages) egil-scim-client; };
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

          inputsFrom = builtins.attrValues packages;
        };
      });
}
