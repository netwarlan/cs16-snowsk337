#!/usr/bin/env bash
set -e

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
║ github.com/netwarlan                          ║
╚═══════════════════════════════════════════════╝"


## Set default values if none were provided
## ==============================================
CS16_SERVER_PORT="${CS16_SERVER_PORT:-27015}"
CS16_SERVER_MAXPLAYERS="${CS16_SERVER_MAXPLAYERS:-32}"
CS16_SERVER_MAP="${CS16_SERVER_MAP:-awp_snowsk337}"
CS16_SVLAN="${CS16_SVLAN:-0}"
CS16_SERVER_HOSTNAME="${CS16_SERVER_HOSTNAME:-SnowSk337 Server}"
CS16_SERVER_UPDATE_ON_START="${CS16_SERVER_UPDATE_ON_START:-false}"
CS16_SERVER_VALIDATE_ON_START="${CS16_SERVER_VALIDATE_ON_START:-false}"
CS16_SERVER_UPDATE_ONLY_THEN_STOP="${CS16_SERVER_UPDATE_ONLY_THEN_STOP:-false}"
CS16_SERVER_VALIDATE_ONLY_THEN_STOP="${CS16_SERVER_VALIDATE_ONLY_THEN_STOP:-false}"
CS16_SERVER_REMOTE_CFG="${CS16_SERVER_REMOTE_CFG:-}"
CS16_SERVER_CONFIG="${CS16_SERVER_CONFIG:-server.cfg}"
[[ -n "$CS16_SERVER_PW" ]] && CS16_SERVER_PW="sv_password $CS16_SERVER_PW"
[[ -n "$CS16_SERVER_RCONPW" ]] && CS16_SERVER_RCONPW="rcon_password $CS16_SERVER_RCONPW"
[[ -n "$CS16_SERVER_FASTDOWNLOAD_URL" ]] && CS16_SERVER_FASTDOWNLOAD_URL="sv_downloadurl \"$CS16_SERVER_FASTDOWNLOAD_URL\""

## Validate critical variables
## ==============================================
if [[ ! "$CS16_SERVER_PORT" =~ ^[0-9]+$ ]]; then
  echo "Error: CS16_SERVER_PORT must be a valid number"
  exit 1
fi
if [[ ! "$CS16_SERVER_MAXPLAYERS" =~ ^[0-9]+$ ]]; then
  echo "Error: CS16_SERVER_MAXPLAYERS must be a valid number"
  exit 1
fi



## Download game files only (without starting server)
## ==============================================
if [[ "$CS16_SERVER_UPDATE_ONLY_THEN_STOP" = true ]] || [[ "$CS16_SERVER_VALIDATE_ONLY_THEN_STOP" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Downloading game files only                   ║
╚═══════════════════════════════════════════════╝"
  if [[ "$CS16_SERVER_VALIDATE_ONLY_THEN_STOP" = true ]]; then
    VALIDATE_FLAG='validate'
  else
    VALIDATE_FLAG=''
  fi

  ## Start downloading game
  "$STEAMCMD_DIR/steamcmd.sh" \
  +force_install_dir "$GAME_DIR" \
  +login "$STEAMCMD_USER" "$STEAMCMD_PASSWORD" "$STEAMCMD_AUTH_CODE" \
  +app_update "$STEAMCMD_APP" $VALIDATE_FLAG \
  +quit

  ## Currently, there is a STEAMCMD bug so we need to get the complete manifests
  echo "Deleting steamapps..."
  rm -rf "$GAME_DIR"/steamapps/*

  ## Download the complete manifests
  for i in 10 70 90; do
    echo "Downloading App Manifest $i"
    wget -q "https://raw.githubusercontent.com/dgibbs64/HLDS-appmanifest/master/CounterStrike/appmanifest_$i.acf" -O ~/Steam/steamapps/appmanifest_$i.acf
  done

  ## Re-attempt game download with correct manifests
  "$STEAMCMD_DIR/steamcmd.sh" \
  +force_install_dir "$GAME_DIR" \
  +login "$STEAMCMD_USER" "$STEAMCMD_PASSWORD" "$STEAMCMD_AUTH_CODE" \
  +app_set_config "$STEAMCMD_APP" mod cstrike \
  +app_update "$STEAMCMD_APP" $VALIDATE_FLAG \
  +quit

  ## Downloading SnowSk337 Map
  ## ==============================================
  echo "
  ╔═══════════════════════════════════════════════╗
  ║ Downloading SnowSk337 Map                     ║
  ╚═══════════════════════════════════════════════╝"
  echo "Deleting all other maps..."
  rm -rf "$GAME_DIR"/cstrike/maps/*

  MAP_DOWNLOAD_URL="https://raw.githubusercontent.com/netwarlan/map-files/main/compressed/awp_snowsk337.zip"
  wget -q "$MAP_DOWNLOAD_URL" -O "$GAME_DIR/awp_snowsk337.zip"
  unzip -o "$GAME_DIR/awp_snowsk337.zip" -d "$GAME_DIR"
  rm -f "$GAME_DIR/awp_snowsk337.zip"
  echo "awp_snowsk337" > "$GAME_DIR/mapcycle.txt"

echo "
╔═══════════════════════════════════════════════╗
║ Game files downloaded. Stopping container.    ║
╚═══════════════════════════════════════════════╝"
  exit 0
fi


## Update on startup
## ==============================================
if [[ "$CS16_SERVER_UPDATE_ON_START" = true ]] || [[ "$CS16_SERVER_VALIDATE_ON_START" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Checking for updates                          ║
╚═══════════════════════════════════════════════╝"
  VALIDATE_FLAG=''
  if [[ "$CS16_SERVER_VALIDATE_ON_START" = true ]]; then
    VALIDATE_FLAG='validate'
  fi

  ## Start downloading game
  "$STEAMCMD_DIR/steamcmd.sh" \
  +force_install_dir "$GAME_DIR" \
  +login "$STEAMCMD_USER" "$STEAMCMD_PASSWORD" "$STEAMCMD_AUTH_CODE" \
  +app_update "$STEAMCMD_APP" $VALIDATE_FLAG \
  +quit

  ## Currently, there is a STEAMCMD bug so we need to get the complete manifests
  echo "Deleting steamapps..."
  rm -rf "$GAME_DIR"/steamapps/*

  ## Download the complete manifests
  for i in 10 70 90; do
    echo "Downloading App Manifest $i"
    wget -q "https://raw.githubusercontent.com/dgibbs64/HLDS-appmanifest/master/CounterStrike/appmanifest_$i.acf" -O ~/Steam/steamapps/appmanifest_$i.acf
  done

  ## Re-attempt game download with correct manifests
  "$STEAMCMD_DIR/steamcmd.sh" \
  +force_install_dir "$GAME_DIR" \
  +login "$STEAMCMD_USER" "$STEAMCMD_PASSWORD" "$STEAMCMD_AUTH_CODE" \
  +app_set_config "$STEAMCMD_APP" mod cstrike \
  +app_update "$STEAMCMD_APP" $VALIDATE_FLAG \
  +quit


  ## Downloading SnowSk337 Map
  ## ==============================================
  echo "
  ╔═══════════════════════════════════════════════╗
  ║ Downloading SnowSk337 Map                     ║
  ╚═══════════════════════════════════════════════╝"
  echo "Deleting all other maps..."
  rm -rf "$GAME_DIR"/cstrike/maps/*

  MAP_DOWNLOAD_URL="https://raw.githubusercontent.com/netwarlan/map-files/main/compressed/awp_snowsk337.zip"
  wget -q "$MAP_DOWNLOAD_URL" -O "$GAME_DIR/awp_snowsk337.zip"
  unzip -o "$GAME_DIR/awp_snowsk337.zip" -d "$GAME_DIR"
  rm -f "$GAME_DIR/awp_snowsk337.zip"
  echo "awp_snowsk337" > "$GAME_DIR/mapcycle.txt"

fi




## Build server config
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Building server config                        ║
╚═══════════════════════════════════════════════╝"
cat <<EOF > "$GAME_DIR/cstrike/$CS16_SERVER_CONFIG"
$CS16_SERVER_PW
$CS16_SERVER_RCONPW
sys_ticrate 1000
sv_timeout 90
fps_max 500
sv_maxrate 25000
sv_minrate 4500
sv_maxupdaterate 101
$CS16_SERVER_FASTDOWNLOAD_URL
sv_allowdownload 1
sv_allowupload 1
host_name_store 1
host_info_show 1
host_players_show 2
EOF




## Download config if needed
## ==============================================
if [[ -n "$CS16_SERVER_REMOTE_CFG" ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Downloading remote config                     ║
╚═══════════════════════════════════════════════╝"
  echo "  Downloading config..."
  CS16_SERVER_CONFIG=$(basename "$CS16_SERVER_REMOTE_CFG")
  curl --silent -O --output-dir "$GAME_DIR/cstrike/" "$CS16_SERVER_REMOTE_CFG"
  echo "  Setting $CS16_SERVER_CONFIG as our server exec"
  chmod 770 "$GAME_DIR/cstrike/$CS16_SERVER_CONFIG"
fi



## Print Variables
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Server set with provided values               ║
╚═══════════════════════════════════════════════╝"
printenv | grep CS16



## Run
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Starting server                               ║
╚═══════════════════════════════════════════════╝"
## Game needs launched in the same directory as hlds_linux
cd "$GAME_DIR"

./hlds_run -game cstrike -console -usercon \
+hostname \"${CS16_SERVER_HOSTNAME}\" \
+exec "$CS16_SERVER_CONFIG" \
+port "$CS16_SERVER_PORT" \
+maxplayers "$CS16_SERVER_MAXPLAYERS" \
+map "$CS16_SERVER_MAP" \
+sv_lan "$CS16_SVLAN"