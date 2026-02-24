{ ... }:

{
  # Use less privileged nixos user
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];
    # Allow the graphical user to login without password
    initialHashedPassword = "";
  };

  # nixos autologin
  services.getty.autologinUser = "nixos";
  # Passwordless sudo
  security.sudo.wheelNeedsPassword = false;
}
