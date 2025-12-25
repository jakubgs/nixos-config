let
  inherit (builtins) filter listToAttrs map attrNames readDir readFile pathExists;

  keyExists = h: pathExists ./${h};
  hostnames = attrNames (readDir ../../hosts);
  hostObj = h: { name = h; value = readFile ./${h}; };
in
  listToAttrs (map hostObj (filter keyExists hostnames))
