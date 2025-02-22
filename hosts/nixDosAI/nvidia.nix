{ pkgs, config, libs, ... }:

{

  # OpenGL and hardware acceleration
  # # this is for 24.05
  # hardware.opengl = {
  #   enable = true;
  #   driSupport = true;
  #   driSupport32Bit = true; # Required for 32-bit applications (e.g., Steam games)
  # };

  # this is for 24.11+
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  
  hardware.nvidia.modesetting.enable = false;
  hardware.nvidia.powerManagement.enable = false;
  hardware.nvidia.powerManagement.finegrained = false;
  hardware.nvidia.open = false;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
}
