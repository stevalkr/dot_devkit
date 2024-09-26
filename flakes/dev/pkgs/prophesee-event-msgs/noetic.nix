{ lib
, buildRosPackage
, fetchFromGitHub
, catkin
, message-generation
, message-runtime
, std-msgs
}:
buildRosPackage rec {
  pname = "ros-noetic-prophesee-event-msgs";
  version = "master";

  src = fetchFromGitHub {
    owner = "ros-event-camera";
    repo = "prophesee_event_msgs";
    rev = "heads/${version}";
    sha256 = "sha256-z8qNxdioHpa2jRT9EQybG10QWkDeV20WD/wPPtZ/SY0=";
  };

  buildType = "catkin";
  buildInputs = [ catkin message-generation ];
  propagatedBuildInputs = [ message-runtime std-msgs ];
  nativeBuildInputs = [ catkin ];

  preConfigure = ''
    export ROS_VERSION=1
  '';

  meta = {
    description = "ROS messages for the prophesee event based cameras";
    license = with lib.licenses; [ asl20 ];
  };
}
