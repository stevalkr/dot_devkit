rec {
  description = "General Dev Environment";

  inputs = {
    ros-overlay.url = "github:lopsided98/nix-ros-overlay/develop";
    nixpkgs.follows = "ros-overlay/nixpkgs";
  };

  outputs = { self, nixpkgs, ros-overlay }:
    ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        lib = pkgs.lib;
        stdenv = pkgs.stdenv;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            ros-overlay.overlays.default
            (final: prev: {
              rosPackages.noetic = prev.rosPackages.noetic.overrideScope (
                (ros-final: ros-prev: {
                  catkin-simple = ros-final.callPackage ./pkgs/catkin-simple.nix { };
                  prophesee-event-msgs = ros-final.callPackage ./pkgs/prophesee-event-msgs/noetic.nix { };
                })
              );

              rosPackages.humble = prev.rosPackages.humble.overrideScope (
                (ros-final: ros-prev: {
                  prophesee-event-msgs = ros-final.callPackage ./pkgs/prophesee-event-msgs/humble.nix { };
                })
              );

              pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                (python-final: python-prev: {
                  rosbags = python-final.callPackage ./pkgs/rosbags.nix { };
                })
              ];
            })
          ];
        };

        ros-distro = "noetic";
        build-ros1 = builtins.elem ros-distro [ "noetic" ];
        build-ros2 = builtins.elem ros-distro [ "humble" "iron" "rolling" ];

        ros-build-env = (with pkgs.rosPackages.${ros-distro}; buildEnv {
          paths =
            lib.optionals build-ros1 [
              rosbash
              ros-core
            ] ++
            lib.optionals build-ros2 [
              ros-core
            ];
        });
      in
      {
        devShell =
          pkgs.mkShell {
            buildInputs = [
              pkgs.fmt
              pkgs.eigen
              pkgs.opencv4
              pkgs.ceres-solver

              ros-build-env

              pkgs.pyright
              pkgs.python3
              pkgs.python3Packages.numpy
              pkgs.python3Packages.scipy
              pkgs.python3Packages.networkx
              pkgs.python3Packages.matplotlib
              pkgs.python3Packages.scikit-learn
            ] ++ lib.optionals stdenv.isDarwin [
              pkgs.libGL
              pkgs.llvmPackages.openmp
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
            '' + lib.optionalString stdenv.isDarwin ''
              export LDFLAGS="$LDFLAGS -L${ros-build-env}/lib -Wl,-rpath,${ros-build-env}/lib"
              export LDFLAGS_LD="$LDFLAGS_LD -L${ros-build-env}/lib -rpath ${ros-build-env}/lib"
            '';
          };
      }
    );

  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
