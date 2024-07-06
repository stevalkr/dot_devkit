rec {
  description = "Livebook Environment";

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
        stdenv = pkgs.stdenvNoCC;

        mkShell = pkgs.mkShell.override
          {
            inherit stdenv;
          };
      in
      mkShell
        {
          nativeBuildInputs = [
            pkgs.cmake
            pkgs.elixir
            pkgs.livebook
            pkgs.elixir-ls
          ];

          shellHook = ''
            echo ${description}
          '';
        };
  };
}
