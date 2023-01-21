{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs.python39Packages) buildPythonPackage fetchPypi evdev;
in buildPythonPackage rec {
  pname = "inputexec";
  version = "0.2.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-AS5l6rTTXe0lBspI5UwwwJlrZutWUOe3IDadoq9L9+Y=";
  };

  propagatedBuildInputs = [ evdev ];

  meta = with pkgs.lib; {
    description = "Simple program to execute commands on keypress on headless systems";
    homepage = "https://github.com/rbarrois/inputexec";
    license = licenses.bsd2;
    maintainers = with maintainers; [ jakubgs ];
  };
}
