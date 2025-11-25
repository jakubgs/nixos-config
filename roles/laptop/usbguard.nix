{ secret, ... }:

{
  # Secrets
  age.secrets."service/usbguard/rules" = {
    file = ../secrets/service/usbguard/rules.age;
  };

  # Protect against malicious USB devices.
  services.usbguard = {
    enable = true;

    implicitPolicyTarget = "block";
    presentControllerPolicy = "keep";
    presentDevicePolicy = "keep";
    insertedDevicePolicy = "block";

    rulesFile = secret "service/usbguard/rules"
  };
}
