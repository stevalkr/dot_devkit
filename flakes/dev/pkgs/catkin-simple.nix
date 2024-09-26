{ lib
, buildRosPackage
, fetchFromGitHub
, catkin
}:
buildRosPackage rec {
  pname = "catkin-simple";
  version = "master";

  src = fetchFromGitHub {
    owner = "catkin";
    repo = "catkin_simple";
    rev = "heads/${version}";
    sha256 = "sha256-PqVPO+4tElNF4/BezzUDvOHeRlZSguSt/574haKPoJU=";
  };

  buildType = "catkin";
  buildInputs = [ catkin ];
  propagatedBuildInputs = [ catkin ];
  nativeBuildInputs = [ catkin ];

  meta = with lib; {
    description = "catkin, simpler";
    homepage = "https://github.com/catkin/catkin_simple";
    platforms = platforms.unix;
    license = licenses.asl20;
  };
}
