{ pkgs, ... }:

{
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ brlaser ];
  };

  # Define printers
  hardware.printers.ensurePrinters = [
    {
      name = "HL2130";
      description = "Brother HL-2130";
      deviceUri = "ipp://192.168.1.100/ipp/port1";
      model = "drv:///brlaser.drv/br2140.ppd";
      ppdOptions = { PageSize = "A4"; };
    }
  ];

  # User packages
  users.users.sochan.packages = with pkgs; [
    a2ps enscript
  ];
}
