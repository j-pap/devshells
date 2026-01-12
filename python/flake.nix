{
  description = "Python";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    { self, nixpkgs, ... }:
    let
      # Python 3.10, 3.11, 3.12, 3.14, or 3.15
      pythonVersion = "3.12";

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
            packages = [
              (pkgs.python3.withPackages (
                pykgs:
                builtins.attrValues {
                  inherit (pykgs)
                    black               # Formatter
                    flake8              # Linter
                    pip                 # Python package manager
                    python-lsp-server   # LSP
                    venvShellHook       # Nix shell venv hook
                  ;
                }
              ))
            ];

            # Environment activation commands
            shellHook = ''
              #python --version
            '';

            # Virtual environment path
            venvDir = "./.venv";

            # Commands to run after creating .venv
            postVenvCreation = ''
              unset SOURCE_DATE_EPOCH
              #pip install -r requirements.txt
            '';

            # Commands to run inside .venv
            postShellHook = ''
              unset SOURCE_DATE_EPOCH
              python --version
            '';
          };
        }
      );

      overlays.default =
        final: prev:
        let
          concatVer =
            v:
            final.lib.strings.concatStrings [
              "${final.lib.versions.major v}"
              "${final.lib.versions.minor v}"
            ];
          python3 = final."python${concatVer pythonVersion}";
        in
        {
          inherit python3;
        };
    };
}
