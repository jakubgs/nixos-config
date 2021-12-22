{ config, ... }:

{
  # Helpers avaialble under config.lib.f.
  lib.f = {
    fqdn = with config.networking; "${hostName}.${domain}";
  };
}
