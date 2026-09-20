# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./disk-config.nix
    ];

  documentation.enable = false;

#  age.secrets.pass.file = ./pass.age;
#  age.identityPaths = [
#    "/persist/etc/ssh/ssh_host_ed25519_key"
#    "/persist/etc/ssh/ssh_host_rsa_key"
#  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
    supportedFilesystems = [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  security.polkit.enable = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      substituters = [
        "https://cache.nixos.org"
        "https://cache.forall.systems/"
      ];
      trusted-users = [ "root" "lilith" ];
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  networking = {
    hostName = "lilith";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];

    enableIPv6 = false;
    networkmanager = {
      enable = true;
      wifi.backend = "wpa_supplicant";
      wifi.powersave = true;
    };

    nftables.enable = true;
    firewall.trustedInterfaces = [ "incusbr0" ];
  };

  # Set your time zone.
  time.timeZone = null;

  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];

  services = {
    openssh.enable = true;

    input-remapper.enable = true;

    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    gnome = {
      core-apps.enable = false;
      core-developer-tools.enable = false;
      games.enable = false;
    };

    dbus = {
      enable = true;
      packages = with pkgs; [ bluez ];
    };

    power-profiles-daemon.enable = false;
    upower.enable = true;
    tlp = {
      enable = true;
      settings = {
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_SAV = "power";

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
    	  PLATFORM_PROFILE_ON_SAV = "low-power";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_BOOST_ON_SAV = 0;

        CPU_HWP_DYN_BOOST_ON_AC = 1;
    	  CPU_HWP_DYN_BOOST_ON_BAT = 0;
    	  CPU_HWP_DYN_BOOST_ON_SAV = 0;

        RUNTIME_PM_ON_AC = "auto";
        RUNTIME_PM_ON_BAT = "auto";

        START_CHARGE_THRESH_BAT0 = 25;
        STOP_CHARGE_THRESH_BAT0 = 85;
      };
    };

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel = {
      npu.enable = true;
      updateMicrocode = true;
    };
    graphics.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."lilith" = {
    isNormalUser = true;
    description = "lilith";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "input"
      "docker"
      "bluetooth"
      "incus-admin"
    ];
    packages = with pkgs; [ ];
#    hashedPasswordFile = config.age.secrets.pass.path;
    initialPassword = "temp-passwd";
    shell = pkgs.zsh;
  };

  programs = {
    zsh.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        zlib
        zstd
        stdenv.cc.cc
        curl
        openssl
        attr
        libssh
        libffi
        bzip2
        libxml2
        acl
        libsodium
        util-linux
        xz
        systemd
        glibc
      ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  virtualisation = {
    incus = {
      enable = true;
      package = pkgs.incus;
      ui.enable = true;
    };
    waydroid.enable = true;
  };

  programs.fuse.userAllowOther = true;
  environment.persistence."/persist/system" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/ssh"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/incus"
      "/var/lib/docker"       
      "/var/lib/waydroid"
      "/etc/NetworkManager/system-connections"
      {
        directory = "/var/lib/lilith";
        user = "lilith";
        group = "lilith";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/machine-id"
      { file = "/etc/nix/id_rsa"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
  };

  systemd.tmpfiles.rules = [
    "d /persist 0755 root root -"
    "d /persist/var/lib 0755 root root -"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
