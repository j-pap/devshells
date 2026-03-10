{
  description = "Python";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    {
      self,
      nixpkgs ? <nixpkgs>,
      ...
    }:
    let
      # https://search.nixos.org/packages?channel=25.11&query=python3
      pythonVer = "3.13"; # 3.10, 3.11, 3.12, 3.13, 3.14, 3.15

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
              (pkgs.python.withPackages (
                pykgs:
                builtins.attrValues {
                  inherit (pykgs)
                    black # Formatter
                    flake8 # Linter
                    pip # Python package manager
                    python-lsp-server # LSP
                    ruff # Formatter/linter/lsp
                    venvShellHook # Nix shell venv hook
                    ;
                }
              ))
            ];

            # Environment activation commands
            shellHook = ''
              python --version
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
          concat =
            v:
            final.lib.strings.concatStrings [
              "${final.lib.versions.major v}"
              "${final.lib.versions.minor v}"
            ];
          python = prev."python${concat pythonVer}";
        in
        {
          inherit python;
        };
    };
}
