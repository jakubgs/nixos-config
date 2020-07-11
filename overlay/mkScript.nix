{ stdenv }:

# Creates a script by substituting @tool@ entries in the file
{ name, file, env ? [ ] }:
  stdenv.mkDerivation {
    name = name;
    src = file;
    buildInputs = env;
    phases = [ "installPhase" ];
    installPhase = ''
      echo $PATH
      substituteAll $src $out
    '';
  }
