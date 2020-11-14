{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.ulogd;
in {
  options = {
    services.ulogd = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable ulogd service.";
      };

      config = mkOption {
        example = ''
          [global]
          stack=log1:NFLOG,base1:BASE,pcap1:PCAP

          [log1]
          group=2

          [pcap1]
          file="/var/log/ulogd.pcap"
          sync=1
        '';
        type = types.lines;
        default = "";
        description = "Ulogd config.";
      };

      logLevel = mkOption {
        type = types.enum [ 1 3 5 7 8 ];
        default = 5;
        description = "Log level (1 = debug, 3 = info, 5 = notice, 7 = error, 8 = fatal)";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ulogd = with pkgs; {
      description = "Ulogd Daemon";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-pre.target" ];
      before = [ "network-pre.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.ulogd}/bin/ulogd -c ${pkgs.writeText "ulogd.conf" cfg.config} --verbose --loglevel ${toString cfg.logLevel}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      };
    };
  };
}
