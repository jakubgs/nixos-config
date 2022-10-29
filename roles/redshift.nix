{ ... }:

{
  # Required for Redshift.
  location = {
    latitude = 52.0;
    longitude = 21.0;
  };

  # Change screen's colour temp. depending on the time of day.
  services.redshift = {
    enable = true;
    temperature = {
      night = 3400;
      day = 5500;
    };
    brightness = {
      night = "0.8";
      day = "1";
    };
  };
}
