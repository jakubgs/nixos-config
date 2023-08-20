{ ... }:

{
  # Hack-Fix for `logrotate.conf` build failures;
  # .../bin/id: cannot find name for group ID 30000
  services.logrotate.checkConfig = false;
}
