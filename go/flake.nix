{
  description = "GoLang";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs =
    { self, nixpkgs, ... }:
    let
      # Go 23 or 24
      goVersion = 24;

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
          default = pkgs.mkShell {
            # Environment variables
            env = { };

            # Packages for the environment
            packages = builtins.attrValues {
              inherit (pkgs)
                delve     # Debugger
                go        # Language binary
                gopls     # LSP - requires latest Go
                go-tools  # Linter | `staticcheck`
                gotools   # Additional modules
              ;
            };

            # Environment activation commands
            shellHook = ''
              go version
            '';
          };
        }
      );

      overlays.default =
        final: prev:
        let
          go = final."go_1_${toString goVersion}";
          buildGoModule = prev.buildGoModule.override { inherit go; };
        in
        {
          inherit go;
          inherit buildGoModule;
        };
    };
}
