# This file is used to load local overrides for secrets fetche
# by the 'secret' function defined in 'roles/secrets.nix'.
# If not found the key is then used to query 'password-store'.
{
  # user password made with mkpasswd -m sha-512
  "hosts/users/jakubgs/pass-hash" = "CHANGE_ME";
  # MAGI WiFi password
  "service/wifi/magi/pass" = "CHANGE_ME";
  # user by music.nix to configure MPD
  "service/mpd/pass" = "CHANGE_ME";
  # Password for Transmission RPC API
  "service/transmission/pass" = "CHANGE_ME";
  # Password for NextCloud admin user
  "service/nextcloud/admin/pass" = "CHANGE_ME";
  # Password for NextCloud DB access
  "service/nextcloud/db/pass" = "CHANGE_ME";
  # ID of ZeroTier private network
  "service/zerotier/magi" = "CHANGE_ME";
  # Web3 URL for Nimbus Eth2 node
  "service/nimbus/web3-url" = "CHANGE_ME";
  # Public IP of server running Nimbus Eth2 node
  "service/nimbus/public-ip" = "CHANGE_ME";
  # Password for FTP user
  "service/vsftpd/pass" = "CHANGE_ME";
  # Discord Web Hook for Prometheus
  "service/alertmanager/discord-webhook" = "CHANGE_ME";
  # Grafana first admin user password
  "service/grafana/pass" = "CHANGE_ME";
  # Password for landing page created by htpasswd
  "service/landing/htpasswd" = "CHANGE_ME";
  # Password for MikroTik read-only prometheus user
  "service/mikrotik/pass" = "CHANGE_ME";
}
