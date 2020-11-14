{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.ulogd;
  settingsFormat = pkgs.formats.ini { };
  settingsFile = settingsFormat.generate "ulogd.conf" cfg.settings;
in {
  options = {
    services.ulogd = {
      enable = mkEnableOption "ulogd";

      settings = mkOption {
        example = {
          global.stack = "stack=log1:NFLOG,base1:BASE,pcap1:PCAP";
          log1.group = 2;
          pcap1 = {
            file = "/var/log/ulogd.pcap";
            sync = 1;
          };
        };
        type = settingsFormat.type;
        default = {};
        description = "Configuration for ulogd. See <literal>./share/doc/ulogd/</literal> in <literal>pkgs.ulogd.doc</literal>.";
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
        ExecStart = "${pkgs.ulogd}/bin/ulogd -c ${settingsFile} --verbose --loglevel ${toString cfg.logLevel}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      };
    };
  };
}
