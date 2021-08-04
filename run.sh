#!/usr/bin/env bash

echo "


╔═══════════════════════════════════════════════╗
║                                               ║
║       _  _____________      _____   ___       ║  
║      / |/ / __/_  __/ | /| / / _ | / _ \      ║
║     /    / _/  / /  | |/ |/ / __ |/ , _/      ║
║    /_/|_/___/ /_/   |__/|__/_/ |_/_/|_|       ║
║                                 OFFICIAL      ║
║                                               ║
╠═══════════════════════════════════════════════╣
║ Thanks for using our DOCKER image! Should you ║
║ have issues, please reach out or create a     ║
║ github issue. Thanks!                         ║
║                                               ║
║ For more information:                         ║
║ https://github.com/netwarlan                  ║
╚═══════════════════════════════════════════════╝
"

## Startup
[[ -z "$CS16_SERVER_PORT" ]] && CS16_SERVER_PORT="27015"
[[ -z "$CS16_SERVER_MAXPLAYERS" ]] && CS16_SERVER_MAXPLAYERS="32"
[[ -z "$CS16_SERVER_MAP" ]] && CS16_SERVER_MAP="awp_snowsk337"

## Config
[[ -z "$CS16_SERVER_HOSTNAME" ]] && CS16_SERVER_HOSTNAME="SnowSk337 Server"
[[ ! -z "$CS16_SERVER_PW" ]] && CS16_SERVER_PW="sv_password $CS16_SERVER_PW"
[[ ! -z "$CS16_SERVER_RCONPW" ]] && CS16_SERVER_RCONPW="rcon_password $CS16_SERVER_RCONPW"

cat <<EOF >$GAME_DIR/cstrike/server.cfg
hostname "$CS16_SERVER_HOSTNAME"
$CS16_SERVER_PW
$CS16_SERVER_RCONPW
EOF


## Update
if [[ "$CS16_SERVER_UPDATE_ON_START" = true ]];
then
echo "
╔═══════════════════════════════════════════════╗
║ Checking for Updates                          ║
╚═══════════════════════════════════════════════╝
"
$STEAMCMD_DIR/steamcmd.sh \
+login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
+force_install_dir $GAME_DIR \
+app_update $STEAMCMD_APP validate \
+quit

echo "
╔═══════════════════════════════════════════════╗
║ SERVER up to date                             ║
╚═══════════════════════════════════════════════╝
"
fi

## Run
echo "
╔═══════════════════════════════════════════════╗
║ Starting SERVER                               ║
╚═══════════════════════════════════════════════╝
  Hostname: $CS16_SERVER_HOSTNAME
  Port: $CS16_SERVER_PORT
  Max Players: $CS16_SERVER_MAXPLAYERS
  Map: $CS16_SERVER_MAP
"
$GAME_DIR/hlds_run -game cstrike -console -usercon +port $CS16_SERVER_PORT +maxplayers $CS16_SERVER_MAXPLAYERS +map $CS16_SERVER_MAP +sv_lan 1 
