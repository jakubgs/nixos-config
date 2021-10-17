{ ... }:

{
  nix.trustedUsers = [ "builder" ];

  users.users.builder = {
    uid = 4000;
    isSystemUser = true;
    createHome = false;
    useDefaultShell = false;
    group = "users";
    extraGroups = [ "kvm" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDARp9kovY6QXa5YqBHyS4LrGVObv01df1fUeuXi75jn0awmBwMpWCAiBcwU4fxqz1X92zivjIrxG4D2InYdOB7TUbGNYVMcz74Vhs2oSdHnNLV9ZaWHRCp8JqhiLF5IdbEoXZGVgIszl3652sfPUs4lVEWwuFgoGNGk6vo+lENqTOIyunqFcdT1z/fb5lOj50ABOhYfEE5/FEjs5jOgoZwW9Rr/HHlDDWRQcpdR4lBhB+MF9DIDyEEJ3cNy5Ll/qZVzhXY179B2FtgS/sAxg3qPpM6+/e6Zm1wWSt5ZDu8OzS3haqzZcWG65r2tkZQxTLFbRyiKZpSbKA2YifyfxfAVdpjw4TVWumlM/xp+RoC46yGCrFz43WdNf20agpDS/l8WQZG+RVuh7SPNYm89R/rq7EnZ3y4ivThDjaAIjKR/lCcoaKavcZSj1HZonom1nuUhhK3YpIeHD3rv8iZpCdVUTLC+TUcoibDuZFexGzfNCRB7h0WX32Qg/GJGSw+VqE= builder@nix.magi.blue"
    ];
  };

  # Enable cross-compiling ARM64 via remote builds.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
