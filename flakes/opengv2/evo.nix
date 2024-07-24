{ lib,
  fetchFromGitHub,
  buildPythonApplication,
  numpy,
  scipy,
  pandas,
  pyyaml,
  pillow,
  tkinter,
  numexpr,
  seaborn,
  natsort,
  colorama,
  pygments,
  matplotlib,
  argcomplete,
  rosbags
}:
buildPythonApplication rec {
  pname = "evo";
  version = "v1.26.2";

  src = fetchFromGitHub {
    owner = "MichaelGrupp";
    repo = "evo";
    rev = "refs/tags/${version}";
    sha256 = "sha256-yp9svvfMgnqm2rGJdjYhajTB1eazMHIGhS6bn4ssyko=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    numpy
    scipy
    pandas
    pyyaml
    pillow
    tkinter
    numexpr
    seaborn
    natsort
    colorama
    pygments
    matplotlib
    argcomplete
    rosbags
    ];

  meta = with lib; {
    homepage = "https://github.com/MichaelGrupp/evo";
    description = "Python package for the evaluation of odometry and SLAM";
    license = licenses.gpl3;
    maintainers = with maintainers; [ etherswangel ];
  };
}


