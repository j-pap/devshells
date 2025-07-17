{
  description = "Various NixOS Devshell Templates";

  outputs =
    { self, ... }:
    {
      # `nix flake init -t github:j-pap/devshells#<template>`
      #    or
      # `nix flake new /path/to/project -t github:j-pap/devshells#<template>`
      templates = {
        default = self.templates.minimal;

        go = {
          path = ./go;
          description = "GoLang";
        };

        minimal = {
          path = ./minimal;
          description = "A minimal environment";
        };

        nodejs = {
          path = ./nodejs;
          description = "NodeJS";
        };

        python = {
          path = ./python;
          description = "Python";
        };
      };
    };
}
