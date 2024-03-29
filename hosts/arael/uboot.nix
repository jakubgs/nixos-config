# This is not used. Use edk2-rk3588 UEFI firmware instead.
{
  pkgs ? import <nixpkgs> {
    crossSystem = { config = "aarch64-unknown-linux-gnu"; };
  }
}:

pkgs.stdenv.mkDerivation {
  name = "uboot-nanopi6";
  version = "v2017.09";

  src = pkgs.fetchFromGitHub {
    owner = "friendlyarm";
    repo = "uboot-rockchip";
    rev = "nanopi6-v2017.09";
    sha256 = "sha256-8zg/7py9FXn+6GY+D5zSAoOk/3NgQj1FMLWBYzZJKZM=";
  };

  srcs = [
    (pkgs.fetchFromGitHub {
      owner = "friendlyarm";
      repo = "rkbin";
      rev = "nanopi6";
      sha256 = "sha256-XGnRUW5Foz0U1V08Kd6Cr/OkwY81xzCzS05irdawWjo=";
    })
  ];

  buildInputs = with pkgs; [ gcc linuxHeaders ];
  nativeBuildInputs = with pkgs; [ which bc dtc python2 binutils glibc autoPatchelfHook ];

  unpackPhase = ''
    cp -r $srcs rkbin
    cp -r $src uboot-rockchip
    find ./ -name 'built-in.o'
    cd uboot-rockchip
  '';

  patchPhase = ''
    chmod -R +w ./ ../rkbin
    autoPatchelf ./ ../rkbin
    patchShebangs make.sh scripts arch

    mkWrap() { echo -e "#!$SHELL\nexec $(which $1) \$@" > /build/bin/$2; }
    mkdir /build/bin
    mkWrap ar aarch64-linux-gnu-ar
    mkWrap aarch64-unknown-linux-gnu-gcc cc
    for TOOL in gcc ld nm readelf objcopy objdump; do
      mkWrap aarch64-unknown-linux-gnu-$TOOL aarch64-linux-gnu-$TOOL
    done
    chmod +x /build/bin/*
    export PATH="/build/bin:$PATH"
  '';

  configurePhase = ''
    echo "CONFIG_FS_FAT=y"   >> configs/nanopi6_defconfig
    echo "CONFIG_FS_EXT4=y"  >> configs/nanopi6_defconfig
    echo "CONFIG_CMD_EXT4=y" >> configs/nanopi6_defconfig
  '';

  buildPhase = ''
    ./make.sh nanopi6
  '';

  installPhase = ''
    mkdir $out
    cp -r /build/uboot-rockchip/uboot.img $out/
  '';

  dontFixup = true;
}
