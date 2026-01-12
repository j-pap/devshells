{
  description = "NodeJS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs, ... }:
    let
      # Node 20 or 24
      nodeVersion = 24;

      supportedSystems = nixpkgs.lib.systems.flakeExposed;
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config = { };
              overlays = [ self.overlays.default ];
            };
          }
        );
    in
    {
      devShells = forEachSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            # Environment variables
            env = { };

            # Packages for the environment
            packages = builtins.attrValues {
              inherit (pkgs)
                nodejs  # Language binary
              ;
            };

            # Environment activation commands
            shellHook = ''
              node --version
            '';
          };
        }
      );

      overlays.default =
        final: prev:
        let
          nodejs = final."nodejs_${toString nodeVersion}";
        in
        {
          inherit nodejs;
          buildNpmPackage = prev.buildNpmPackage.override { inherit nodejs; };
        };
    };
}
