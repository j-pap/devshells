{
  description = "GoLang";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    {
      self,
      nixpkgs ? <nixpkgs>,
      ...
    }:
    let
      # https://search.nixos.org/packages?channel=25.11&query=go_1_
      goVer = 24; # 24, 26

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
                delve # Debugger
                go # Language binary
                gopls # LSP - requires latest Go
                go-tools # Linter | `staticcheck`
                gotools # Additional modules
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
          go = prev."go_1_${toString goVer}";
          buildGoModule = prev.buildGoModule.override { inherit go; };
        in
        {
          inherit go;
          inherit buildGoModule;
        };
    };
}
