self: super:

{
  lib = super.lib // {
    mkScript = self.callPackage ./mkScript.nix { };
  };
  mkScript = self.callPackage ./mkScript.nix { };
}
