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
      night = 3700;
      day = 5500;
    };
    brightness = {
      night = "0.7";
      day = "1";
    };
  };
}
