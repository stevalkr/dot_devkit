rec {
  description = "OpenGV2 Environment";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-23.11-darwin;
    mesa-nixpkgs.url = github:nixos/nixpkgs/c2ebb395cadfd081c015f7da5034b12c145bf6bc;
  };

  outputs = { self, nixpkgs, mesa-nixpkgs }:
    let
      system = "aarch64-darwin"; # ["x86_64-linux" "aarch64-darwin"]
      pkgs = import nixpkgs {
        inherit system;
      };
      mesa-pkgs = import mesa-nixpkgs {
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

          rosbags = pkgs.python3Packages.callPackage ./rosbags.nix { };
          evo = pkgs.python3Packages.callPackage ./evo.nix { rosbags = rosbags; };

          ceres-solver =
            pkgs.callPackage ./ceres-solver.nix { };

          sophus =
            pkgs.callPackage ./sophus.nix { };

          pangolin =
            pkgs.callPackage ./pangolin.nix {
              glew = mesa-pkgs.glew;
              libGL = mesa-pkgs.libGL;
              Cocoa = pkgs.darwin.apple_sdk.frameworks.Cocoa;
              Carbon = pkgs.darwin.apple_sdk.frameworks.Carbon;
            };
        in
        mkShell
          {
            buildInputs = [
              sophus
              pangolin
              ceres-solver
              pkgs.fmt
              pkgs.eigen
              pkgs.opencv
              pkgs.nanoflann

              evo
              pkgs.pyright
              pkgs.python3
              pkgs.python3Packages.numpy
              pkgs.python3Packages.scipy
              pkgs.python3Packages.matplotlib

              mesa-pkgs.glew
              mesa-pkgs.libGL
            ];

            nativeBuildInputs = [
              pkgs.cmake
              pkgs.clang-tools
            ];

            shellHook = ''
              echo ${description}
            '';
          };
    };
}
