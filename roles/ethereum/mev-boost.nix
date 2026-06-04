{ unstablePkgs, ... }:

{
  imports = [ ../services/mev-boost.nix ];

  services.mev-boost = {
    enable = true;
    logJson = true;
    logLevel = "info";
    package = unstablePkgs.mev-boost;
    relays = [
      "https://0xac6e77dfe25ecd6110b8e780608cce0dab71fdd5ebea22a16c0205200f2f8e2e3ad3b71d3499c54ad14d6c21b41a37ae@boost-relay.flashbots.net"
      "https://0xa00001792da52b2ad6606033396337f86e7598c8e0927d640bb649e0a9fe230df41f8ffd3403a5cd4fffd5131e2fbe47@rsync-builder.xyz"
      "https://0x8c4ed5e24fe5c6ae21018437bde147693f68cda427cd1122cf20819c30eda7ed74f72dece09bb313f2a1855595ab677d@global.titanrelay.xyz"
      "https://0xa7ab7a996c8584251c8f925da3170bdfd6ebc75d50f5ddc4050a6fdc77f2a3b5fce2cc750d0865e05d7228af97d69561@agnostic-relay.net"
    ];
  };
}
