rec {
  description = "Cpp Environment";

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
            pkgs.fmt
            pkgs.eigen
            pkgs.ceres-solver
          ];

          nativeBuildInputs = [
            pkgs.cmake
            pkgs.ninja
            pkgs.clang-tools
          ];

          shellHook = ''
            echo ${description}
          '';
        };
  };
}
