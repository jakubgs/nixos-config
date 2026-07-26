{ unstablePkgs, ... }:

{
  imports = [ ../../services/mev-boost.nix ];

  services.mev-boost = {
    enable = true;
    logJson = true;
    logLevel = "info";
    package = unstablePkgs.mev-boost;
    relays = [
      "https://0xa1559ace749633b997cb3fdacffb890aeebdb0f5a3b6aaa7eeeaf1a38af0a8fe88b9e4b1f61f236d2e64d95733327a62@relay.ultrasound.money"
      "https://0x8b5d2e73e2a3a55c6c87b8b6eb92e0149a125c852751db1422fa951e42a09b82c142c3ea98d0d9930b056a3bc9896b8f@bloxroute.max-profit.blxrbdn.com"
      "https://0x8c4ed5e24fe5c6ae21018437bde147693f68cda427cd1122cf20819c30eda7ed74f72dece09bb313f2a1855595ab677d@global.titanrelay.xyz"
    ];
  };
}
