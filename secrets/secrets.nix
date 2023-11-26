let
  # Users
  yubikey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeWB4SeXQfEsfkNPOkSLoTQ/7VDpf8CsaRQ+waCHEEv4v2fFc/9lMbQ6Z208UEQKJMOMdtwd3eB7j6aFIirMQTYcm/NuxPLdRRnlxLNJIVMBfKUV5V3OkbneqzBTEvtAaIDC506kIlXxAPfZCDVxzAi7B+NkHUvhjCEjScM2KfamahDZUbj2ww2Q/82P1Qj8QY/1b2wC6OXBnKPUQIzAzrxDNYWaXdB/4DysDcib50kd2URenpMVU1DCjSWXBniSnpEVh0Lxjehsnfg+oE3BP3u6wA+1xufukH9h9eQ/hTM1PXEVC2ObpgESRYxc3rqkqVxYbOzrmCRVJpvKoGs+W89vIoFUt6/tzunAMogo2VHhT7LnGE4iizj9YODxIdpRMGGeMgZiceoOuNFAjKg8Qay4aoE50uklim4ircOXgrAasRotUcz28EU5oaV9/NO+GKNzooRNBX2U/c1MsTI+6mz7ppMq0NCHOpO5sY1qC8F2lZbDDGQgC25btqu+xnbqHwCDSst2Sy5yvF3C34F/Xt8kw3zkraB1OmTWwW/QIA+o3AViaA59r+ZicIIEWvUbUbcMD/GFDesOgzK8V9G6kZNuQoEVsq9FHEMTpsGSBDOIHn4aWP+7gQK2FhvyXBGj/z/NDFY1H+I2KvhI0rkV3NaTtUy0+51uKO5Efnx8cQyw== openpgp:0x64A63589";
  personal = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAotJTAk91kQ4skl7hDT5h5GwC/dWCfDXJiQMTw4QrgpNI7rxLhQbgorvN287bzrVig5xBQloMkkm9qqzOn2cv5L7iit8TT9mcrApDiqWBrb05jCm5cu1lINni/MWn5XfQMnE8YnWtwnW+ncd2EcwS9wVDabrTJPFjFYnMaHbl7Ls= jakubgs@lilim";
  jakubgs = [ yubikey personal ];

  # Hosts
  arael   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKWuMU4bc01lGYg78sQtZ9nJxUstrHKgLCVNQRjAylx";
  bardiel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAFeYOpASuZicvTRTkQi4rnWPRIsoo/BDXb60rQUVfKE";
  caspair = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAytofq4RnQGkuFR1IVR7oe1sGF3EvHt1nMkhO35xjr3";
  israfel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIABuBuXETx6a08ZrzW1ejLHu4g0E3vLtrEc9FSyFPV9E";
  lilim   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBho3kbFApYVDfkvTtLMBsz00qi20U5ozx4G02jD1oPL";
  sachiel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMDWD0UjBeW9VG5DLMqc4sBHXFZmUEaD9bz/XFL2mXD";
  zeruel  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2g2ZcL5+T+LNLXaXU2T6kWIb8TTCE2W9LvTiyostsO";
  systems = [ arael bardiel caspair israfel lilim sachiel zeruel ];

  all = jakubgs ++ systems;
in {
  "hosts/users/jakubgs/pass-hash.age" = { publicKeys = all;     };
  "service/grafana/pass.age"          = { publicKeys = bardiel; };
  "service/landing/htpasswd.age"      = { publicKeys = all;     };
  "service/mikrotik/config.age"       = { publicKeys = arael;   };
  "service/mpd/pass.age"              = { publicKeys = all;     };
  "service/transmission/creds.age"    = { publicKeys = all;     };
  "service/zerotier/magi.age"         = { publicKeys = all;     };
  "service/wifi.age"                  = { publicKeys = all;     };
}
