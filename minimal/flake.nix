{
  description = "";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs, ... }:
    let
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
      #lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
      #version = "0-unstable-" + builtins.substring 0 8 lastModifiedDate;
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
                cowsay
                hello
                lolcat
              ;
            };

            # Environment activation commands
            shellHook = ''
              hello | cowsay | lolcat
            '';
          };
        }
      );

      overlays.default = final: prev: { };
    };
}
