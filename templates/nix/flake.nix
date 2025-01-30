rec {
  description = "Shell Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        lib = pkgs.lib;
        stdenv = pkgs.stdenv;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              python3PackagesExtensions = prev.python3PackagesExtensions ++ [
                (python-final: python-prev: {
                })
              ];
            })
          ];
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
          ];

          nativeBuildInputs = [
            pkgs.nixd
            pkgs.nixpkgs-fmt
            pkgs.ninja
            pkgs.meson
            pkgs.cmake
            pkgs.cmake-format
            pkgs.clang-tools
          ];

          shellHook = ''
            echo ${description}
          '';
        };
      }
    );
}
