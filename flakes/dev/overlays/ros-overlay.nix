final: prev:
{
  catkin-simple = final.callPackage ../pkgs/catkin-simple.nix { };
  prophesee-event-msgs = final.callPackage ../pkgs/prophesee-event-msgs.nix { };
}
