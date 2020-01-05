#
# This is a hack for defining available variables
# See: https://discourse.nixos.org/t/variables-for-a-system/2342/7
#
{ lib, ... }:

{
  options = {
    vars = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };
}
