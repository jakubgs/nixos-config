{ secret, ... }:

{
  # Secrets
  age.secrets."service/usbguard/rules" = {
    file = ../../secrets/service/usbguard/rules.age;
  };

  # Protect against malicious USB devices.
  services.usbguard = {
    enable = true;

    implicitPolicyTarget = "block";
    presentControllerPolicy = "keep";
    presentDevicePolicy = "keep";
    insertedDevicePolicy = "apply-policy";

    # Use 'usbguard generate-policy' to expand rules.
    ruleFile = secret "service/usbguard/rules";
  };
}
