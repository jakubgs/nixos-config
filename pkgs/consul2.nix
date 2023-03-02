{ pkgs, lib, ... }:

pkgs.python39Packages.buildPythonPackage rec {
  pname = "python-consul2";
  version = "0.1.5";

  src = pkgs.python39Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-KchZ3nPhfzarmb6DH9wdkk8W6HciMyd6KO+St7mZlc0=";
  };

  propagatedBuildInputs = with pkgs.python39Packages; [ six requests ];

  # Some tests require Consul binaries.
  doCheck = false;

  meta = with lib; {
    description = "Extended Python client for Consul";
    homepage = "https://github.com/poppyred/python-consul2";
    license = licenses.mit;
    maintainers = with maintainers; [ jakubgs ];
  };
}