{ lib,
  fetchFromGitLab,
  buildPythonPackage,
  lz4,
  numpy,
  zstandard,
  ruamel-yaml,
  setuptools
}:
buildPythonPackage rec {
  pname = "rosbags";
  version = "v0.9.19";

  src = fetchFromGitLab {
    owner = "ternaris";
    repo = "rosbags";
    rev = "refs/tags/${version}";
    sha256 = "sha256-4kZIr44uTIRaNzOM1JOId7CgRU4mJZxUm4ka2OuRupE=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    lz4
    numpy
    zstandard
    ruamel-yaml
    setuptools
    ];

  prePatch = ''
    echo -e "from setuptools import setup" >> setup.py
    echo -e "if __name__ == '__main__':" >> setup.py
    echo -e "    setup()" >> setup.py
  '';

  meta = with lib; {
    homepage = "https://gitlab.com/ternaris/rosbags";
    description = "Rosbags is the pure python library for everything rosbag";
    license = licenses.asl20;
    maintainers = with maintainers; [ etherswangel ];
  };
}

