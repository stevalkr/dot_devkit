{ lib
, fetchFromGitLab
, buildPythonPackage
, lz4
, numpy
, zstandard
, ruamel-yaml
, typing-extensions
, setuptools
}:
buildPythonPackage rec {
  pname = "rosbags";
  version = "v0.10.4";

  src = fetchFromGitLab {
    owner = "ternaris";
    repo = "rosbags";
    rev = "refs/tags/${version}";
    sha256 = "sha256-2LkhIsNgeGIAESWT7Cgh9TeTXQUuXhk4qjbC/f/K1RU=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    lz4
    numpy
    zstandard
    ruamel-yaml
    typing-extensions
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
    platforms = platforms.unix;
    license = licenses.asl20;
  };
}
