rec {
  description = "Awrit";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-24.05-darwin;
  };

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
        inherit system;
      };
  in
  {
    defaultPackage.${system} =
      let
        awrit =
          { lib
          , stdenv
          , fetchFromGitHub
          , cmake
          , ninja
          , libs
          , Cocoa
          , Carbon
          , CoreMediaIO
          }:

          stdenv.mkDerivation rec {
            pname = "awrit";
            version = "unstable-2024-01-01";

            src = fetchFromGitHub {
              owner = "chase";
              repo = pname;
              rev = "heads/main";
              sha256 = "sha256-ziRml1GItzg91Ze8zbHzyCD20A69y97MVQln3Z34xaE=";
            };

            nativeBuildInputs = [ cmake ninja ];

            buildInputs = [
            ]
            ++ lib.optionals stdenv.isDarwin [
              Cocoa
              Carbon
              CoreMediaIO
              libs.sandbox
            ];

            configurePhase = ''
              cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$out .
            '';

            buildPhase = ''
              ninja
            '';

            installPhase = ''
              ninja install
            '';

            meta = {
              description = "A full graphical web browser for Kitty terminal with mouse and keyboard support";
              homepage = "https://github.com/chase/awrit";
              license = lib.licenses.bsd3;
              maintainers = with lib.maintainers; [ etherswangel ];
            };
          };
      in
      pkgs.callPackage awrit {
          libs        = pkgs.darwin.apple_sdk.libs;
          Cocoa       = pkgs.darwin.apple_sdk.frameworks.Cocoa;
          Carbon      = pkgs.darwin.apple_sdk.frameworks.Carbon;
          CoreMediaIO = pkgs.darwin.apple_sdk.frameworks.CoreMediaIO;
        };
  };
}
