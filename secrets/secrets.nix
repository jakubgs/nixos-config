let
  # Users
  yubikey  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeWB4SeXQfEsfkNPOkSLoTQ/7VDpf8CsaRQ+waCHEEv4v2fFc/9lMbQ6Z208UEQKJMOMdtwd3eB7j6aFIirMQTYcm/NuxPLdRRnlxLNJIVMBfKUV5V3OkbneqzBTEvtAaIDC506kIlXxAPfZCDVxzAi7B+NkHUvhjCEjScM2KfamahDZUbj2ww2Q/82P1Qj8QY/1b2wC6OXBnKPUQIzAzrxDNYWaXdB/4DysDcib50kd2URenpMVU1DCjSWXBniSnpEVh0Lxjehsnfg+oE3BP3u6wA+1xufukH9h9eQ/hTM1PXEVC2ObpgESRYxc3rqkqVxYbOzrmCRVJpvKoGs+W89vIoFUt6/tzunAMogo2VHhT7LnGE4iizj9YODxIdpRMGGeMgZiceoOuNFAjKg8Qay4aoE50uklim4ircOXgrAasRotUcz28EU5oaV9/NO+GKNzooRNBX2U/c1MsTI+6mz7ppMq0NCHOpO5sY1qC8F2lZbDDGQgC25btqu+xnbqHwCDSst2Sy5yvF3C34F/Xt8kw3zkraB1OmTWwW/QIA+o3AViaA59r+ZicIIEWvUbUbcMD/GFDesOgzK8V9G6kZNuQoEVsq9FHEMTpsGSBDOIHn4aWP+7gQK2FhvyXBGj/z/NDFY1H+I2KvhI0rkV3NaTtUy0+51uKO5Efnx8cQyw== openpgp:0x64A63589";
  fallback = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGUXvuXqZwlLOSxYqthiWF1J5U4E93SUGDu7gk4Ok30T jakubgs";
  jakubgs = [ yubikey fallback ];

  # Hosts
  hosts = import ../keys/hosts/ed25519;
  systems = builtins.attrValues hosts;

  all = jakubgs ++ systems;
in with hosts; {
  # Host Private Keys
  "hosts/keys/ed25519/arael.age"       = { publicKeys = jakubgs;   };
  "hosts/keys/ed25519/bardiel.age"     = { publicKeys = jakubgs;   };
  "hosts/keys/ed25519/caspair.age"     = { publicKeys = jakubgs;   };
  "hosts/keys/ed25519/gaghiel.age"     = { publicKeys = jakubgs;   };
  "hosts/keys/ed25519/israfel.age"     = { publicKeys = jakubgs;   };
  "hosts/keys/ed25519/zeruel.age"      = { publicKeys = jakubgs;   };
  # Other Secrets
  "hosts/users/jakubgs/pass-hash.age"  = { publicKeys = all;       };
  "service/alertmanager/webhook.age"   = { publicKeys = all;       };
  "service/grafana/pass.age"           = { publicKeys = jakubgs ++ [ bardiel ]; };
  "service/invidious/hmac-key.age"     = { publicKeys = jakubgs ++ [ arael bardiel iruel ]; };
  "service/landing/server.key.age"     = { publicKeys = all;       };
  "service/mikrotik/config.age"        = { publicKeys = jakubgs ++ [ arael ];   };
  "service/mpd/pass.age"               = { publicKeys = all;       };
  "service/nimbus/fee-recipient.age"   = { publicKeys = jakubgs ++ [ israfel zeruel bardiel ]; };
  "service/nimbus/web3-jwt-secret.age" = { publicKeys = jakubgs ++ [ israfel zeruel bardiel ]; };
  "service/nix-serve/nix.magi.vpn"     = { publicKeys = jakubgs ++ [ bardiel ]; };
  "service/nixos-activation/key.age"   = { publicKeys = all;       };
  "service/tailscale/auth-key.age"     = { publicKeys = jakubgs ++ [ caspair lilim ]; };
  "service/transmission/creds.age"     = { publicKeys = all;       };
  "service/usbguard/rules.age"         = { publicKeys = all;       };
  "service/vsftpd/pass.age"            = { publicKeys = all;       };
  "service/wifi.age"                   = { publicKeys = all;       };
  "service/zerotier/magi.age"          = { publicKeys = all;       };
}
