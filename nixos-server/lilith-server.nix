{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  userName = "lilith";
  hostName = userName + "-server";
in {
  imports = [
    ./disk-config.nix
  ];

  age.secrets = {
    usr-pwd.file = .../secrets/usr-pwd.age;
  };

  # System configuration
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
  };

  powerManagement = {
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  # Nix configuration
  nixpkgs.config.allowUnfree = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # Networking configuration
  networking = {
    hostName = hostName;
    nftables.enable = true;
    useNetworkd = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "outbr0" "intbr0" ];
    };
  };

  systemd.network = {
    enable = true;
    wait-online.ignoredInterfaces = [ "outbr0" ];
    networks = {
      "10-physical" = {
        matchConfig.Name = [ "en*" "eth*" ];
        networkConfig = {
          LinkLocalAddressing = "no";
          DHCP = "no";
          Bridge = "outbr0";
        };
      };
      "15-bridge" = {
        matchConfig.Name = "outbr0";
        networkConfig = {
          DHCP = "yes";
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
    netdevs = {
      "20-outbr0" = {
        netdevConfig = {
          Name = "outbr0";
          Kind = "bridge";
        };
      };
    };
  };

  # Impermanence configuration
  programs.fuse.userAllowOther = true;
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/incus"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /persist 0755 root root -"
    "d /persist/var/lib 0755 root root -"
  ];

  # Virtualisation - Incus
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    ui.enable = true;
    preseed = {
      networks = [
        {
          config = {
            "ipv4.address" = "10.0.100.1/24";
            "ipv4.nat" = "true";
          };
          name = "intbr0";
          type = "bridge";
        }
      ];

      profiles = [
        {
          devices = {
            eth0 = {
              type = "nic";
              nictype = "bridged";
              parent = "outbr0";
              name = "eth0";
            };
            root = {
              path = "/";
              pool = "default";
              size = "35GiB";
              type = "disk";
            };
          };
          name = "default-external";
          description = "Default profile with external network access";
        }
        {
          devices = {
            eth0 = {
              type = "nic";
              network = "intbr0";
              name = "eth0";
            };
            root = {
              path = "/";
              pool = "default";
              size = "35GiB";
              type = "disk";
            };
          };
          name = "default-internal";
          description = "Default profile with internal network access";
        }
      ];

      storage_pools = [
        {
          config = {
            source = "/var/lib/incus/storage-pools/default";
          };
          driver = "btrfs";
          name = "default";
        }
      ];

      config = {
        "core.https_address" = ":8443";
        "core.metrics_address" = ":8444";
      };
    };
  };

  users = {
    mutableUsers = false;
    users = {
      "${userName}" = {
        isNormalUser = true;
        extraGroups = [ "wheel" "incus-admin" ];
        openssh.authorizedKeys.keys = [ ];
        hashedPasswordFile = config.age.secrets.usr-pwd.path;
        packages = with pkgs; [
          mc
          btop
          curl
          wget
          powertop
          pciutils
          cpufrequtils
          smartmontools
        ];
      };
    };
  };

  security.sudo.extraRules= [
    {
      users = [ "${userName}" ];
      commands = [{
        command = "ALL" ;
        options = [ "NOPASSWD" ];
      }];
    }
  ];

  services = {
    openssh = {
      enable = true;
      ports = [ 1444 ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
