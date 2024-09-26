{ lib
, buildRosPackage
, fetchFromGitHub
, ament-cmake
, rosidl-default-generators
, rosidl-default-runtime
, std-msgs
}:
buildRosPackage rec {
  pname = "ros-humble-prophesee-event-msgs";
  version = "master";

  src = fetchFromGitHub {
    owner = "ros-event-camera";
    repo = "prophesee_event_msgs";
    rev = "heads/${version}";
    sha256 = "sha256-z8qNxdioHpa2jRT9EQybG10QWkDeV20WD/wPPtZ/SY0=";
  };

  buildType = "ament_cmake";
  buildInputs = [ ament-cmake rosidl-default-generators ];
  propagatedBuildInputs = [ rosidl-default-runtime std-msgs ];
  nativeBuildInputs = [ ament-cmake rosidl-default-generators ];

  preConfigure = ''
    export ROS_VERSION=2
  '';

  meta = {
    description = "ROS messages for the prophesee event based cameras";
    license = with lib.licenses; [ asl20 ];
  };
}
