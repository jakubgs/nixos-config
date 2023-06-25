{ buildLinux, fetchFromGitHub, ... }@args:

buildLinux (args // rec {
  kernelPatches = [];
  version = "5.10.110";
  modDirVersion = "5.10.110";
  defconfig = "rockchip_linux_defconfig";

  # do not automatically try to load other modules
  autoModules = false;

  src = fetchFromGitHub {
    owner = "friendlyarm";
    repo = "kernel-rockchip";
    rev = "43b4cf5fed84b5dd62f0fc1df73bca9524381c69"; # nanopi5-v5.10.y_op
    sha256 = "sha256-CqolIhYTNNFnIPvT+0bPCaKFgud6Z0hta6gqo37TJzI=";
  };
} // (args.argsOverride or {}))
