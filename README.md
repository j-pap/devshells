# NixOS Development Shells

Follow the directions below to use these with your system.

## 01. Add flake to Nix registry

```nix
nix.registry.devshells.to = {
  type = "github";
  owner = "j-pap";
  repo = "devshells";
};
```

## 02. Enable direnv

```nix
programs.direnv.enable = true;
```

## 03. Initialize your project

Replace `template_name` below with the name of one of the directories in this
repository.

### A. Use an existing directory

```bash
cd /path/to/project
nix flake init -t devshells#template_name
```

### B. Create a new directory

```bash
nix flake new /path/to/project -t devshells#template_name
```

## 04. Permit direnv

Inside your freshly initialized directory, run the command below. This will
create a flake.lock file, downloading all the packages specified, while also
permitting direnv to load the development environment automatically every time
the directory is entered.

```bash
direnv allow
```
