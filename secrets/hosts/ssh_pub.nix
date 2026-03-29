let
  inherit (builtins) filter listToAttrs map attrNames readDir readFile pathExists;

  hostnames = attrNames (readDir ./.);
  hostObj = h: { name = h; value = readFile ./${h}/ssh/ed25519.pub; };
  keyExists = h: pathExists ./${h}/ssh/ed25519.pub;
in
  # Returns object with hostnames as keys and ed25519.pub as value.
  listToAttrs (map hostObj (filter keyExists hostnames))
