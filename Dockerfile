FROM centos:latest

## Update our container and install a few packages
RUN yum update -y \
    && yum install -y \
       curl \
       glibc.i686 \
       libstdc++.i686 \
       unzip \
       wget \
    && yum clean all

## Create Environment Variables
## Game Specific
ENV GAME="cstrike" \
    USER="steam" \
    GAME_DIR="/docker/cstrike" \

## SteamCMD Specific
    STEAMCMD_APP="90" \
    STEAMCMD_USER="anonymous" \
    STEAMCMD_PASSWORD="" \
    STEAMCMD_AUTH_CODE="" \
    STEAMCMD_DIR="/docker/steamcmd"

## Setup USER and HOME directory
RUN useradd -m -d /docker $USER -s /bin/bash

## Change USER
USER $USER

## Create base folders
RUN mkdir -p $GAME_DIR \
    && mkdir -p $STEAMCMD_DIR \

    ## Download SteamCMD
    && curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xzC $STEAMCMD_DIR \
    && $STEAMCMD_DIR/steamcmd.sh \
        +login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
        +force_install_dir $GAME_DIR \
        +app_update $STEAMCMD_APP \
        +app_set_config $STEAMCMD_APP mod $GAME validate \
        +quit \

    ## Currently, there is an HLSW Bug, so we need to manually download the manifests for STEAMCMD
    || rm -rf $GAME_DIR/steamapps/* \
    && for i in 10 70 90; do wget -q https://raw.githubusercontent.com/dgibbs64/HLDS-appmanifest/master/CounterStrike/appmanifest_$i.acf -O ~/Steam/steamapps/appmanifest_$i.acf; done \
    && $STEAMCMD_DIR/steamcmd.sh \
        +login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
        +force_install_dir $GAME_DIR \
        +app_update $STEAMCMD_APP \
        +app_set_config $STEAMCMD_APP mod cstrike validate \
        +quit \

    ## Create Scripting for the game
    && echo '#!/bin/bash' > $GAME_DIR/start.sh \
    && echo './hlds_run -game $GAME -console -usercon $@' >> $GAME_DIR/start.sh \

    ## Create symlinks and appdata for Steam
    && mkdir -p ~/.steam/sdk32 \
    && ln -s $GAME_DIR/steamclient.so ~/.steam/sdk32/steamclient.so \
    && echo '10' > $GAME_DIR/steam_appid.txt \

    ## Delete all maps - do not need them + helps with size of image
    && rm -rf $GAME_DIR/cstrike/maps/* \

    ## Download AWP_SNOWSK337 map and extract
    && wget -q https://files.gamebanana.com/maps/_7136-.zip -O $GAME_DIR/awp_snowsk337.zip \
    && unzip -o $GAME_DIR/awp_snowsk337.zip -d $GAME_DIR \

    ## Modify our SERVER.CFG file to include some modifiers
    && echo -e "\nsys_ticrate 1000 \
       \nsv_timeout 90 \
       \nfps_max 500 \
       \nsv_maxrate 25000 \
       \nsv_minrate 4500 \
       \nsv_maxupdaterate 101" >> $GAME_DIR/cstrike/server.cfg \

    ## Make sure we only play SnowSK337
    && echo "awp_snowsk337" > $GAME_DIR/cstrike/mapcycle.txt \

    ## Flatten permissions
    && chmod -R ug+rwx ~

## Set working directory and normal start up process
WORKDIR $GAME_DIR

## Start here
ENTRYPOINT ["./start.sh"]
CMD ["+map", "awp_snowsk337", "+maxplayers", "32"]
