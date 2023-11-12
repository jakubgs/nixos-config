{ pkgs, secret, ... }:

{
  # Give extra permissions with Nix
  nix.settings.trusted-users = [ "jakubgs" ];

  users.groups.jakubgs = {
    gid = 1000;
    name = "jakubgs";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jakubgs = {
    uid = 1000;
    createHome = true;
    isNormalUser = true;
    useDefaultShell = true;
    group = "jakubgs";
    hashedPassword = secret "hosts/users/jakubgs/pass-hash";
    extraGroups = [
      "wheel" "audio" "dialout" "video" "disk"
      "adm" "tty" "systemd-journal" "docker"
      "networkmanager" "cdrom"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeWB4SeXQfEsfkNPOkSLoTQ/7VDpf8CsaRQ+waCHEEv4v2fFc/9lMbQ6Z208UEQKJMOMdtwd3eB7j6aFIirMQTYcm/NuxPLdRRnlxLNJIVMBfKUV5V3OkbneqzBTEvtAaIDC506kIlXxAPfZCDVxzAi7B+NkHUvhjCEjScM2KfamahDZUbj2ww2Q/82P1Qj8QY/1b2wC6OXBnKPUQIzAzrxDNYWaXdB/4DysDcib50kd2URenpMVU1DCjSWXBniSnpEVh0Lxjehsnfg+oE3BP3u6wA+1xufukH9h9eQ/hTM1PXEVC2ObpgESRYxc3rqkqVxYbOzrmCRVJpvKoGs+W89vIoFUt6/tzunAMogo2VHhT7LnGE4iizj9YODxIdpRMGGeMgZiceoOuNFAjKg8Qay4aoE50uklim4ircOXgrAasRotUcz28EU5oaV9/NO+GKNzooRNBX2U/c1MsTI+6mz7ppMq0NCHOpO5sY1qC8F2lZbDDGQgC25btqu+xnbqHwCDSst2Sy5yvF3C34F/Xt8kw3zkraB1OmTWwW/QIA+o3AViaA59r+ZicIIEWvUbUbcMD/GFDesOgzK8V9G6kZNuQoEVsq9FHEMTpsGSBDOIHn4aWP+7gQK2FhvyXBGj/z/NDFY1H+I2KvhI0rkV3NaTtUy0+51uKO5Efnx8cQyw== cardno:9 020 049"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5NIT2SVFFjV+ZraPBES45z8wkJf769P7AXdZ4FiJw+DcXKawNJCUefeBQY5GVofVOzOHUrkYLqzxVJihIZJaDgeyME/4pLXYztkk9EOWdQSadxLJjWItMJULJrh5nnXzKxv5yy1SGJCTcMSXrvR6JRduu+KTHGncXJ2Ze6Bdgm63sOdfyPCITSC+nc4GexYLAQmBxXCwtKieqfWVmKpazlVDxAg3Q1h2UXOuLTjkWomvzVCggwhzHtN/STQMCH49PlW/VoIBlrpYqlmRGObsdBae4Bk/D5ZpisJi6w573RcF9q3VrqJTHLiSpntfVJEtsbmyiNNckIujQfRk2KYvSCK2iGP17hfCE9HmEfSZNWrKrMqKJ7gHOhXHJrszh6TtN9zmgomPvYolJBLz/2/JC8swfixHPMzxQa+P2NyqC0yWg8Xqd1JLWKLHsLwpEYvmOfyYIY8zOfk7y3OJX8h7D/fgbnG/V75EVuZDc8sqXTJpj3esoEsz8XVu9cVraAOodG4zYKFnoTomAzBJtImh6ghSEDGT5BAvDyFySyJGMibCsG5DwaLvZUcijEkKke7Z7OoJR4qp0JABhbFn0efd/XGo2ZyGtJsibSW7ugayibEK7bDaYAW3lNXgpcDqpBiDcJVQG/UhhCSSrTsG0IUSbvSsrDuF6gCJWVKt4+klvLw== openpgp:0x8F1C7F9B" # 2022-11-21 - 2023-11-21
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+57Jq2iKok+GPouS70IMPj3+FC9nIbO6kJgdSS0H1DcsDjRz9XvBUSmsxKk864HsnuwTSQgENqWx03d1lhTRYaAL5AOUC/97LsdpFY8jNMOlhBh5YU0HtLYT8MtYBaeBV4XSHo/XiWL6RDQ0NI3C5QlXAKxFEVuhnrLiia0GirnUnUtqg9I2aFmZ8gQ1U0UJxUOb2MPLkj2EuKGF0WfLZycHai6VhXLD5Ki6VIynKN6yxyEzE3TFrc4C7m5FVffWtD9xPc8ueJkFDfQll6T53JrFFpLJq0dvlyH8ICPvgNR///q+2oizJn9sfQKZlY3Y8BwrOyFVrRq6JpWRVvVDx5EvqkvKr5UKdvT03ltgVvDZLN+8tyRLpfTFKw0TenlAINDvgIW7sYpZJvv+R4Qp9mH9W1xoqbcsakCU18vbJdvZf5zkh+dSak+3eLgfDk4mD87fmkij4NDs4aIumRQgP9NVdbkbKjBWoDMxopoM7pNaAUkvTBYt5wn4FOWjwfem7WsSVqmx9qEJ4XbOWkjwhceWvcVcyLUV54QujxzP+wTmqvrQrkHF0IzXfWktnF04THvTxDfyRZ/MQqYcho/wNxsHw1qrTpLfwkLJl9k12kTnraDzXZ83op30chNj5t9+z2s7uJuwQkrew0lmPq6S1VJ+cEvcDmiU/4/MudUIacQ== openpgp:0x8AF1DFDE" # 2023-11-12 - 2024-11-11
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDoSmZuJeFZCrLP5ErZUnWNzrDymrIdfSnIaZi713Gj1frzu7qUN1DTEZkzR4rz3tx3jy8iez0z1dF88sQYyHxq/8uVGiEzxyzLv+fnO+N9dCKHGKw0zfMsio2d12ca9gXFvs0MasJJ7iNfem2USaKtL4tIbaZ/too+mnwwdnIFDZ4vU34s38L/mosKB30kndDJognxNfDmdyh+dRsKlRg92wzI/QG7cDFYTLRuPcTL0WTnmWaFfazqs5ukocnNle7xRW/XqrBVUnACldPPfvWwRlAjYAtKhJPQZAPZF2qonn43xx6maJY1fgfgrtUY7QAMC/NzmpmhrDROazyEhQD/R+D+WBrYhp1FX8d8XkNJrEJrnHrd4NxDWw9tF5Z49a5nkUbD4l9gtbAMooFTqszRicQ8Y0F52XMr0PQY/u/wm6S3qSORcJkdwTsBQUk+SCOkPkjy6OfyggU0ZtD+TYkj0FPYc6bwk1xxAROqpclzEfGpVODqdX56Lio00OB6cf0= openpgp:0x1571357C" # 2023-11-12 - 2025-11-11
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDA6mutbRHO8VvZ61MYvjIVv1Re9NiJGE1piTQq4IFwXOvAi1HkXkMlsjmzYt+CEv0HmMGCHmdrw5xpqnDTWg18lM5RYLzrAv9hBOQ10IC+8FH2XWDKoyz+PBQsNEbbJ23QQtu0O5mpsOzI/KBT9CkiYUYlEBwHI0vNqsdHDLwv3Yt7PhauguXDHpYnwH/OseVHLBg2+/3aJIfOMVVRnhptQGYAhTNUZ9F1EwvQETMhM/vEsk8+o9B3tK/Ii/RD2EtVUlpRG4q6QTFbssLMImUfcdoggHsfCqjq3apUs8bR81oN9UVoYiP8tn5sWIUyRBxIEzXpqa4rx04KY8xNYqeZ jakub@status.im"
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAotJTAk91kQ4skl7hDT5h5GwC/dWCfDXJiQMTw4QrgpNI7rxLhQbgorvN287bzrVig5xBQloMkkm9qqzOn2cv5L7iit8TT9mcrApDiqWBrb05jCm5cu1lINni/MWn5XfQMnE8YnWtwnW+ncd2EcwS9wVDabrTJPFjFYnMaHbl7Ls= jakubgs@lilim"
    ];
  };

  # allow of sudo without password
  security.sudo.wheelNeedsPassword = false;

  system.userActivationScripts = {
    jakubgsDotfiles = let
      dotfilesSh = pkgs.substituteAll {
        src = ../files/dotfiles.sh;
        isExecutable = true;
        inherit (pkgs) bash git coreutils findutils gnused;
      };
    in "${dotfilesSh}";
  };
}
