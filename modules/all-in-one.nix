{ config, lib, pkgs, contrailPkgs, ... }:

with lib;

let

  cfg = config.contrail.allInOne;

in {

    options = {
      contrail.allInOne = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
        vhostInterface = mkOption {
          type = types.str;
          default = "eth1";
          description = "Physical interface name to which virtual host interface maps to";
        };
        vhostIP = mkOption {
          type = types.str;
          default = "192.168.1.1";
        };
      };
    };

    imports = [
      ./cassandra.nix
      ./contrail-vrouter-agent.nix
      ./contrail-api.nix
      ./contrail-schema-transformer.nix
      ./contrail-svc-monitor.nix
      ./contrail-discovery.nix
      ./contrail-analytics-api.nix
      ./contrail-query-engine.nix
      ./contrail-collector.nix
      ./contrail-control.nix
    ];

    config = rec {

      networking.firewall.enable = false;

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      environment.systemPackages = with pkgs; [
        contrailApiCliWithExtra
      ];

      contrail = {
        vrouterAgent = {
          enable = true;
          vhostInterface = cfg.vhostInterface;
          vhostIP = cfg.vhostIP;
        };
        discovery.enable = contrailPkgs.isContrail32;
        api.enable = true;
        schemaTransformer.enable = true;
        svcMonitor.enable = true;
        analyticsApi.enable = true;
        queryEngine.enable = true;
        collector.enable = true;
        control.enable = true;
      };

   };
}
