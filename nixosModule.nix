{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  mkOption =
    type: description: default:
    lib.mkOption {
      description = description;
      type = type;
      default = default;
    };
  mkStrOption = mkOption lib.types.str;
  mkIntOption = mkOption lib.types.int;
  defaultBorkerPort = 4000;
  cfg = config.services.ivhs-broker;
  package = self.packages.${pkgs.system}.default;
  releaseName = "ivhs_broker";
in
{
  options.services.ivhs-broker = {
    enable = lib.mkEnableOption "Enable ivhs-broker service";

    port = mkIntOption "IVHS Port" defaultBorkerPort;
    releaseCookie = mkStrOption "IVHS Release cookie" "ivhs-broker-cookie";
    name = mkStrOption "IVHS app name" "ivhs-app";
    user = mkStrOption "IVHS user" "ivhs";
    group = mkStrOption "IVHS group" "wheel";
    version = mkStrOption "Broker version (docker image tag)" "latest";
    databaseUrl = mkStrOption "Postgres database url" "postgresql://postgres:postgres@postgres/postgres";
    secretKeyBase = mkStrOption "IVHS Secret key base" (
      builtins.hashString "sha256" "ivhs-broker.secret_key_base"
    );
    liveViewSalt = mkStrOption "IVHS Secret key base" (
      builtins.hashString "sha256" "ivhs-broker.live_view_salt"
    );
    app_host = mkStrOption "App's hostname" "http://localhost:${toString defaultBorkerPort}";
    loggerLevel = mkStrOption "Logger's level" "info";
    emitterDebounce = mkIntOption "Emitter's debounce" 1000;
    mqtt = {
      host = mkStrOption "MQTT Broker hostname" "localhost";
      port = mkIntOption "MQTT Broker port" 1883;
      clientId = mkStrOption "IVHS Broker client id on MQTT broker" "ivhs-player";
      username = mkStrOption "MQTT Broker username" "ivhs";
      password = mkStrOption "MQTT Broker password" "ivhs";
    };
    plex = {
      host = mkStrOption "Plex hostname" "";
      token = mkStrOption "Plex token" "";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.ivhs-broker =
      let
        buildScript = body: ''
          export RELEASE_COOKIE="${cfg.releaseCookie}"
          export RELEASE_NODE=ivhs_broker@127.0.0.1
          export RELEASE_DISTRIBUTION=name
          export LOGGER_LEVEL=${cfg.loggerLevel}

          ${body}
        '';
      in
      {
        description = "IVHS Broker";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        script = buildScript ''
          ${package}/bin/${releaseName} start
        '';
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          ExecStop = buildScript ''
            ${package}/bin/${releaseName} stop
          '';
          ExecReload = buildScript ''
            ${package}/bin/${releaseName} restart
          '';
        };
        environment = {
          MIX_ENV = "prod";
          PORT = "${toString cfg.port}";
          DATABASE_PATH = cfg.databaseUrl;
          SECRET_KEY_BASE = cfg.secretKeyBase;
          LIVE_VIEW_SALT = cfg.liveViewSalt;
          APP_HOST = cfg.app_host;
          LOGGER_LEVEL = cfg.loggerLevel;
          EMITTER_DEBOUNCE = "${toString cfg.emitterDebounce}";
          MQTT_HOST = cfg.mqtt.host;
          MQTT_PORT = "${toString cfg.mqtt.port}";
          MQTT_CLIENT_ID = cfg.mqtt.clientId;
          MQTT_USERNAME = cfg.mqtt.username;
          MQTT_PASSWORD = cfg.mqtt.password;
          PLEX_HOST = cfg.plex.host;
          PLEX_TOKEN = cfg.plex.token;
        };
      };
  };
}
