rec {
  description = "Devkit Environment";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-24.05-darwin;
  };

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-darwin"; # ["x86_64-linux" "aarch64-darwin"]
    pkgs = import nixpkgs {
        inherit system;
      };
  in
  {
    devShells.${system}.default =
      let
        stdenv = pkgs.clangStdenv;

        mkShell = pkgs.mkShell.override
          {
            inherit stdenv;
          };
      in
      mkShell
        {
          buildInputs = [
            pkgs.lua
            pkgs.fmt
            pkgs.doctest
            pkgs.cxxopts
            pkgs.yaml-cpp
          ];

          nativeBuildInputs = [
            pkgs.ninja
            pkgs.cmake
            pkgs.meson
            pkgs.ccache
            pkgs.pkg-config
            pkgs.clang-tools
            pkgs.lua-language-server
          ];

          shellHook = ''
            echo ${description}
          '';
        };
  };
}
