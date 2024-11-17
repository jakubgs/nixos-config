{ ... }:

{
  # Remote terminal application that allows roaming, supports
  # intermittent connectivity, and provides intelligent
  # local echo and line editing of user keystrokes.
  # https://mosh.org/
  programs.mosh = {
    enable = true;
    withUtempter = true;
    openFirewall = true;
  };
}
