## Pull our base image
FROM ubuntu:18.04

## Image Information
LABEL maintainer="Jeff Nelson <jeff@netwar.org>"
ARG DEBIAN_FRONTEND=noninteractive

## Set Build Arguments
ENV GAME_DIR="/app/cstrike" \
    GAME_USER="steam" \
    STEAMCMD_APP="90" \
    STEAMCMD_USER="anonymous" \
    STEAMCMD_PASSWORD="" \
    STEAMCMD_AUTH_CODE="" \
    STEAMCMD_DIR="/app/steamcmd"

## Start building our server
RUN dpkg --add-architecture i386
RUN apt-get update \
    && apt-get install -y \
        curl \
        lib32gcc1 \
        lib32ncurses5 \
        lib32stdc++6 \
        lib32tinfo5 \
        lib32z1 \
        libc6:i386 \
        libcurl3-gnutls:i386 \
        libncurses5 \
        libncurses5:i386 \
        libstdc++6:i386 \
        zlib1g:i386 \
        libsdl2-2.0-0:i386 \
        unzip \
        wget \
    && apt-get clean \
    && rm -rf /var/tmp/* /var/lib/apt/lists/* /tmp/* \

    ## Create Directory Structure
    && mkdir -p $GAME_DIR \
    && mkdir -p $STEAMCMD_DIR \

    ## Create our User
    && useradd -ms /bin/bash $GAME_USER \

    ## Set Directory Permissions
    && chown -R $GAME_USER:$GAMEUSER $GAME_DIR \
    && chown -R $GAME_USER:$GAMEUSER $STEAMCMD_DIR

## Change to our User
USER $GAME_USER

## Download SteamCMD
RUN curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -xzC $STEAMCMD_DIR \
    && $STEAMCMD_DIR/steamcmd.sh \
        +login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
        +force_install_dir $GAME_DIR \
        +app_update $STEAMCMD_APP validate \
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
    && wget -q https://files.gamebanana.com/mods/_7136-.zip -O $GAME_DIR/awp_snowsk337.zip \
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

## Copy our run script into the image
COPY run.sh $GAME_DIR/run.sh

## Set working directory
WORKDIR $GAME_DIR

## Start the run script
CMD ["bash", "run.sh"]
