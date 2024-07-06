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
    owner = "prophesee-ai";
    repo = "prophesee_ros_wrapper";
    rev = "heads/${version}";
    sha256 = "sha256-EZAQ7c4zFQ7qSLhZCY36pdFeBCm1BPoGwjhgdhfRmdg=";
  };

  sourceRoot = "${src.name}/prophesee_event_msgs";

  buildType = "catkin";
  buildInputs = [ catkin message-generation ];
  propagatedBuildInputs = [ message-runtime std-msgs ];
  nativeBuildInputs = [ catkin ];

  meta = {
    description = "The prophesee_event_msgs package";
    license = with lib.licenses; [ asl20 ];
  };
}
