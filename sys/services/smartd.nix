{ ... }:

{
  services.smartd = {
    enable = true;
    autodetect = false;
    defaults.monitored = "-a -o on";
    devices = [
      # daily SHORT (00-04h, staggered) | weekly LONG Sat 03-07h —
      # sdf (8 TB SMR, ~14 h long test) runs LONG on WED so it never overlaps
      # the Sunday 03:30 borg window; no LONG test touches Sunday at all.
      { device = "/dev/sda"; options = "-s (S/../.././00|L/../../6/03)"; }  # WD20EARX 2 TB
      { device = "/dev/sdb"; options = "-s (S/../.././01|L/../../6/04)"; }  # WD6400AAKS ~2009
      { device = "/dev/sdc"; options = "-s (S/../.././02|L/../../6/05)"; }  # WD10EZEX 1 TB
      { device = "/dev/sdd"; options = "-s (S/../.././03|L/../../6/06)"; }  # Kingston SSD (root)
      { device = "/dev/sde"; options = "-s (S/../.././04|L/../../6/07)"; }  # WD1001FALS ~2011
      { device = "/dev/sdf"; options = "-s (S/../.././05|L/../../3/03)"; }  # ST8000DM004 SMR: LONG Wednesday
    ];
  };
}
