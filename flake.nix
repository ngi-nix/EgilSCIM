{
  description = "The EGIL SCIM client";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays = {
        egil-scim-client = final: prev:
          {
            egil-scim-client = with final; stdenv.mkDerivation rec {
              pname = "egil-scim-client";
              version = "2.7.0";
              src = self;

              strictDeps = true;

              buildInputs = [
                boost
                curl      # libcurl
                openldap  # libldap
              ];

              nativeBuildInputs = [
                cmake
              ];

              installPhase = ''
                mkdir -p $out/bin/
                cp EgilSCIMClient $out/bin/
              '';

              meta = {
                description = "The EGIL SCIM client";
                longDescription = ''
                  The EGIL SCIM client implements the EGIL profile of the SS
                  12000 standard.  It reads information about students, groups
                  etc. from LDAP and sends updates to a SCIM server.
                '';
                homepage =
                  "https://www.skolfederation.se/egil-scimclient-esc/";
                license = nixpkgs.lib.licenses.agpl3Plus;
                maintainers = [];
              };
            };
          };
      };

      overlay = self.overlays.egil-scim-client;
    } // flake-utils.lib.eachDefaultSystem(system:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
    in
    rec {
      packages = {
        inherit (pkgs) egil-scim-client;
      };

      defaultPackage = pkgs.egil-scim-client;

      apps = {
        egil-scim-client = flake-utils.lib.mkApp {
          drv = packages.egil-scim-client;
          exePath = "/bin/EgilSCIMClient";
        };
      };

      defaultApp = apps.egil-scim-client;
    });
}
