{ lib
, stdenv
, fetchFromGitHub
, fmt
, cmake
, eigen
}:
stdenv.mkDerivation {
  pname = "sophus";
  version = "1.22.10";

  src = fetchFromGitHub {
    owner = "strasdat";
    repo = "Sophus";
    rev = "1.22.10";
    hash = "sha256-TNuUoL9r1s+kGE4tCOGFGTDv1sLaHJDUKa6c9x41Z7w=";
  };

  buildInputs = [ eigen fmt ];
  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DBUILD_SOPHUS_TESTS=OFF"
  ];

  meta = with lib; {
    homepage = "https://github.com/strasdat/Sophus";
    description = "C++ implementation of Lie Groups using Eigen";
    license = licenses.mit;
    maintainers = with maintainers; [ etherswangel ];
    platforms = platforms.unix;
  };
}
