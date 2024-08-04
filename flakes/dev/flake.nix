rec {
  description = "General Dev Environment";

  inputs = {
    ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs.follows = "ros-overlay/nixpkgs";
  };

  outputs = { self, nixpkgs, ros-overlay }:
    ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (system:
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

              pkgs.libGL
              pkgs.darwin.apple_sdk.frameworks.Cocoa
              pkgs.darwin.apple_sdk.frameworks.Carbon
              pkgs.darwin.apple_sdk.frameworks.OpenGL
              pkgs.darwin.apple_sdk.frameworks.GLUT

              (with pkgs.rosPackages.noetic; buildEnv {
                paths = [
                  rosbash
                  ros-core
                ];
              })
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

  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
