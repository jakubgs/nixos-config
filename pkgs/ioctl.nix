{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "ioctl";
  version = "d5610a5106df276c226fd0015191c5e9b504b0e4";

  src = pkgs.fetchFromGitHub {
    owner = "jerome-pouiller";
    repo = "ioctl";
    rev = version;
    hash = "sha256-tuDwekKC5ag6Sri7aXdVFrwAtbjLkmHCAweovRClFrw=";
  };

  buildInputs = with pkgs; [ linuxHeaders ];

  patchPhase = ''
    sed -i 's#\$SYSROOT/usr#${pkgs.linuxHeaders}#' gen_ioctls_list.sh
    sed -i '/^.PHONY: ioctls_list.c/d' Makefile
  '';

  configurePhase = ''
    runHook preConfigure
    make ioctls_list.c
    runHook postConfigure
  '';

  postConfigure = ''
    sed -i '/DMA_BUF_SET_NAME_/d' ioctls_list.c
    grep -e EVIOCGID -e EVIOCGNAME -e EVIOCGPHYS -e EVIOCGUNIQ ioctls_list.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ioctl $out/bin
  '';

  meta = with pkgs.lib; {
    description = "The missing tool to call arbitrary ioctls on devices";
    homepage = "https://github.com/jerome-pouiller/ioctl";
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jakubgs ];
  };
}
