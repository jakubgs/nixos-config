{ secret, ... }:

{
  # Secrets
  age.secrets."service/nix-serve/nix.magi.vpn" = {
    file = ../secrets/service/nix-serve/nix.magi.vpn.age;
  };

  services.nix-serve = {
    enable = true;
    openFirewall = false;
    port = 5000;
    bindAddress = "0.0.0.0";
    # Public Key: nix.magi.vpn:Q00cvekd+F+fSujdWFHEWwbkCAozwdaOve6pK/P3aFA=
    secretKeyFile = secret "service/nix-serve/nix.magi.vpn";
  };
}
