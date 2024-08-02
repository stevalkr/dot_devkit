{ lib
, buildRosPackage
, fetchFromGitHub
, catkin
}:
buildRosPackage rec {
  pname = "ros-noetic-catkin-simple";
  version = "master";

  src = fetchFromGitHub {
    owner = "catkin";
    repo = "catkin_simple";
    rev = "heads/${version}";
    sha256 = "sha256-PqVPO+4tElNF4/BezzUDvOHeRlZSguSt/574haKPoJU=";
  };

  buildType = "catkin";
  buildInputs = [ catkin ];
  nativeBuildInputs = [ catkin ];

  meta = {
    description = "catkin, simpler";
    license = with lib.licenses; [ asl20 ];
  };
}
