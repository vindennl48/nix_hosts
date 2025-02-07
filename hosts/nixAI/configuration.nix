# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # Import unstable channel (replace REVISION with current unstable commit)
  unstable = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "1da52dd49a127ad74486b135898da2cef8c62665";  # Get latest from https://status.nixos.org/
    sha256 = "sha256-KRwX9Z1XavpgeSDVM/THdFd6uH8rNm/6R+7kIbGa+2s="; # Get from error message when you try with wrong hash
  }) { config = config.nixpkgs.config; };
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./nvidia.nix
      ./hardware-configuration.nix
    ];

  nixpkgs.overlays = [
    (self: super: {
      lmstudio39 = super.callPackage ./lmstudio.nix { };
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     neovim gcc xclip
     git
     less
     wget
     nh
     # unstable.lmstudio
     lmstudio39
  ];

  programs = {
    zsh.enable = true;
    firefox.enable = true;
  };

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  systemd = {
    targets = {
      sleep.enable = true;
      suspend.enable = true;
      hibernate.enable = true;
      hybrid-sleep.enable = true;
    };
  };

  networking = {
    hostName = "nixAI"; # Define your hostname.
    networkmanager.enable = true;
  };

  services = {
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      # Enable the GNOME Desktop Environment.
      displayManager = {
        gdm.enable = true;
        gdm.settings.daemon.DefaultSession = "gnome-xorg.desktop";
      };
      desktopManager.gnome.enable = true;

      # Configure keymap in X11
      layout = "us";
      xkbVariant = "";
    };

    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
      };
    };

    xrdp = {
      enable = true;
      openFirewall = true;
      defaultWindowManager = "${pkgs.gnome.gnome-session}/bin/gnome-session";
    };

    # set up KVM guest tools
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mitch = {
    isNormalUser = true;
    description = "mitch";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
