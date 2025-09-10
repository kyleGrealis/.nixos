{ config, lib, pkgs, ...}: {

  networking.networkmanager.enable = true;

  # Mount piCloud over CIFS/SMB & tailnet:
  fileSystems."/home/kyle/piCloud" = {
    device = "//100.125.173.109/piCloud";
    fsType = "cifs";
    options = [
      "credentials=/home/kyle/.nixos/smb-secrets"
      "uid=1000"
      "gid=1000"
      "vers=3.0"
      "nofail" # Don't fail boot if mount fails
      "_netdev" # Mark as a network device
      "x-systemd.automount" # Automount on access
      "x-systemd.requires=tailscaled.service"
      "x-systemd.requires=network-online.target"

      # timing delays to prevent boot or shutdown hanging:
      "x-systemd.idle-timeout=300" # 5 minutes of inactivity
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /home/kyle/piCloud 0755 kyle users -"
  ];

}
