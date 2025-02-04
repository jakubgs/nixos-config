{ pkgs, ... }:

{
  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      brlaser       # Brother HL-2135 (Home)
      epson-201401w # EPSON L365 (Mazury)
    ];
  };

  # Define printers
  hardware.printers.ensurePrinters = [
    {
      name = "HL2130_NET";
      description = "Brother HL-2130 NET";
      deviceUri = "ipp://192.168.1.100/ipp/port1";
      model = "drv:///brlaser.drv/br2140.ppd";
      ppdOptions = { PageSize = "A4"; };
    }
  ];

  # User packages
  users.users.jakubgs.packages = with pkgs; [
    a2ps enscript
  ];
}
