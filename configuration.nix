#===============================================================================
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
#===============================================================================


#===============================================================================
# config, lib, pkgs
#===============================================================================

{ config, lib, pkgs, ... }:


#===============================================================================
# import - hardware-configuration.nix
#===============================================================================

{
imports =
  [
    ./hardware-configuration.nix
  ];


#===============================================================================
# boot
#===============================================================================

boot = {
  # clean tmp on boot
  tmp.cleanOnBoot = true;

  # use the systemd-boot EFI boot loader.
  loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
};


#===============================================================================
# nix 
#===============================================================================

nix = {
  settings = {
    # auto-optimise-store
    auto-optimise-store = true;
    # flakes
    experimental-features = [ "nix-command" "flakes" ];
  };

  # nix garbage collection
  gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
};


#===============================================================================
# nixpkgs
#===============================================================================

nixpkgs = {
  config = {
    allowUnfree = true;
  
    # broadcom fix permitted insecure packages
    allowInsecurePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "broadcom-sta" # aka “wl”
    ];
 };
};


#===============================================================================
# console keymap
#===============================================================================

console.keyMap = "us";


#===============================================================================
# time zone
#===============================================================================

time.timeZone = "Europe/London";


#===============================================================================
# environment.sessionVariables - comsic clipboard
#===============================================================================

environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;


#===============================================================================
# Select internationalisation properties.
#===============================================================================

i18n = {
  defaultLocale = "en_GB.UTF-8";
  extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
};


#===============================================================================
# users
#===============================================================================

users = {
  mutableUsers = true; # mutable user set a password with ‘passwd’

  # user
  users.djwilcox = {
    shell = pkgs.zsh; # shell
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
  };
};


#===============================================================================
# hardware graphics
#===============================================================================

hardware = {
 graphics = {
   enable = true;
   extraPackages = with pkgs; [
     intel-vaapi-driver
     libva-vdpau-driver
     libvdpau-va-gl
  ];
 };
};
  

#===============================================================================
# services
#===============================================================================

services = {
  dbus.packages = [ pkgs.xdg-desktop-portal-cosmic ]; # dbus
  system76-scheduler.enable = true; # cosmic scheduler

 # xserver
  xserver = {
    enable = true;

   # xkb
    xkb = {
      layout = "gb";
      variant = "mac";
      };
    };

  # Enable the COSMIC login manager
  displayManager.cosmic-greeter.enable = true;
  
  # Enable the COSMIC desktop environment
  desktopManager.cosmic.enable = true;
  
  openssh.enable = true; # ssh
  thermald.enable = true;
  printing.enable = false; # disable cups printing
  libinput.enable = true;  # libinput - touchpad
  
  # pipewire
  pipewire = {
    enable = true;
    pulse.enable = true;
  };
};


#===============================================================================
# security 
#===============================================================================

security = {
  sudo.enable = true;  # sudo
  rtkit.enable = true; # rtkit for audio

  # doas
  doas = {
    enable = true;
    extraConfig = ''
      # allow user
      permit keepenv setenv { PATH } djwilcox
      
      # allow root to switch to our user
      permit nopass keepenv setenv { PATH } root as djwilcox
  
      # nopass
      permit nopass keepenv setenv { PATH } djwilcox
  
      # nixos-rebuild switch
      permit nopass keepenv setenv { PATH } djwilcox cmd nixos-rebuild
      
      # root as root
      permit nopass keepenv setenv { PATH } root as root
    '';
  };
};


#===============================================================================
# networking
#===============================================================================

networking = {
  hostName = "castor"; # Define your hostname.
  hostId = "37725d60"; # hostid
  networkmanager.enable = true;  # network manager

  # firewall
  # Open ports in the firewall.
  # transmission ports 6881 6882

  firewall = {
  # allowedTCPPorts
  allowedTCPPorts = [ 6881 ];

  # allowedUDPPorts
  allowedUDPPorts = [ 6882 ];
  };
};


#===============================================================================
# XDG Desktop Portal Configuration for Wayland
#===============================================================================

xdg.portal = {
  enable = true;

  extraPortals = [ 
    pkgs.xdg-desktop-portal-cosmic
    pkgs.xdg-desktop-portal-gtk
  ];

  config = {
    # Default for all sessions
    common.default = [ "gtk" ];
    
    # Specific override for your COSMIC session
    cosmic.default = [ "cosmic" ];
  };
};


#===============================================================================
# programs
#===============================================================================

programs = {
  # zsh shell
  zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
   };


  # dconf
  dconf.enable = true;

  # mtr
  mtr.enable = true;

   gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
};


#===============================================================================
# systemPackages
#===============================================================================

environment.systemPackages = with pkgs; [
  vim # Do not forget to add an editor to edit configuration.nix!
  xdg-desktop-portal-cosmic
];


#===============================================================================
# system.stateVersion
#===============================================================================

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
