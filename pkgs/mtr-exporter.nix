{ pkgs ? import <nixpkgs> { } }:

pkgs.buildGoModule rec {
  pname = "mtr-exporter";
  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "mgumz";
    repo = "mtr-exporter";
    rev = "ab0b97a987c000ebf526691a6a84fbc5890bd632";
    sha256 = "0715az97ipn36b35h6ys1jqhlcl8w6w0qzg7rnbgj4fraip2nfdg";
  };

  vendorSha256 = "0njn0ac7j3lv8ax6jc3bg3hh96a42jal212qk6zxrd46nb5l1rj8";

  patches = [ ./mtr-exporter.patch ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Mtr-exporter periodically executes mtr to a given host and provides the measured results as prometheus metrics.";
    homepage = "https://github.com/mgumz/mtr-exporter";
    license = licenses.bsd3;
    maintainers = with maintainers; [ jakubgs ];
  };
}
