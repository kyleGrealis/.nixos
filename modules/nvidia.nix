# module/nvidia.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Load NVIDIA driver for Xorg & Wayland
  hardware = {
    # Ref: https://wiki.nixos.org/wiki/NVIDIA
    graphics.enable = true;

    nvidia = {
      open = true;
      # package = config.boot.kernelPackages.nvidiaPackages.stable; # Default
      prime = {
        offload.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  # For offloading, `modesetting` is needed additionally,
  # otherwise the X-server will be running permanently on nvidia,
  # thus keeping the GPU always on (see `nvidia-smi`).
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  # Kernel configuration
  boot = {
    blacklistedKernelModules = ["nouveau"]; # default when using proprietary drivers
    kernelParams = ["nvidia-drm.modeset=1"];
  };

  # Environment variables
  environment = {
    variables = {
      LIBVA_DRIVER_NAME = "nvidia";
    };

    systemPackages = with pkgs; [
      nvidia-modprobe
      nvtopPackages.full

      # NVIDIA offload script
      (writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec "$@"
      '')
    ];
  };
}
