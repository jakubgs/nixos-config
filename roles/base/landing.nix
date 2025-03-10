{ secret, ... }:

{
  imports = [
    ../../services/landing.nix
  ];

  age.secrets."service/landing/server.key" = {
    file = ../../secrets/service/landing/server.key.age;
    owner = "nginx";
  };

  # Load MAGI Certificate Authority
  security.pki.certificateFiles = [ ../../secrets/service/landing/ca.crt ];

  services.landing = {
    enable = true;
    sslCertificateKey = secret "service/landing/server.key";
    sslCertificate    = ../../secrets/service/landing/server.crt;
    clientCertificate = ../../secrets/service/landing/ca.crt;
    revokeList        = ../../secrets/service/landing/crl.pem;
  };
}
