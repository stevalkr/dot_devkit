rec {
  description = "General Dev Environment";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-24.05-darwin;
    ros-overlay.url = github:lopsided98/nix-ros-overlay;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, ros-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            ros-overlay.overlays.default
            (final: prev: {
              rosPackages.noetic =
                prev.rosPackages.noetic.overrideScope (
                  import ./overlays/ros-overlay.nix
                );
            })
          ];
        };
      in
      {
        devShell =
          pkgs.mkShell {
            buildInputs = [
              pkgs.fmt
              pkgs.eigen
              pkgs.opencv4
              pkgs.ceres-solver
              pkgs.llvmPackages.openmp

              pkgs.pyright
              pkgs.python3
              pkgs.python3Packages.numpy
              pkgs.python3Packages.scipy
              pkgs.python3Packages.networkx
              pkgs.python3Packages.matplotlib
              pkgs.python3Packages.scikit-learn

              # pkgs.colcon
              # pkgs.python3Packages.catkin-tools
              pkgs.rosPackages.noetic.rosbash
              pkgs.rosPackages.noetic.ros-core
              # pkgs.rosPackages.noetic.catkin-simple
              # pkgs.rosPackages.noetic.prophesee-event-msgs

              pkgs.libGL
              pkgs.darwin.apple_sdk.frameworks.Cocoa
              pkgs.darwin.apple_sdk.frameworks.Carbon
              pkgs.darwin.apple_sdk.frameworks.OpenGL
              pkgs.darwin.apple_sdk.frameworks.GLUT
            ];

            nativeBuildInputs = [
              pkgs.gcc
              pkgs.ninja
              pkgs.cmake
              pkgs.meson
              pkgs.gtest
              pkgs.cpplint
              pkgs.cppcheck
              pkgs.pkg-config
              pkgs.nixd
              pkgs.nixpkgs-fmt
              pkgs.clang-tools
              pkgs.cmake-format
              pkgs.markdownlint-cli
              pkgs.lua-language-server
            ];

            shellHook = ''
              echo ${description}
            '';
          };
      }
    );
}
