## Pull our base image
FROM debian:12-slim

## Image Information
LABEL maintainer="Jeff Nelson <jeff@netwar.org>"
ARG DEBIAN_FRONTEND=noninteractive

## Set Build Arguments
ENV APP_DIR="/app" \
    GAME_DIR="/app/cstrike" \
    GAME_USER="steam" \
    STEAMCMD_APP="90" \
    STEAMCMD_USER="anonymous" \
    STEAMCMD_PASSWORD="" \
    STEAMCMD_AUTH_CODE="" \
    STEAMCMD_DIR="/app/steamcmd"

## Start building our server
RUN dpkg --add-architecture i386 \
    && apt update \
    && apt install -y \
        curl \
        lib32gcc-s1 \
        lib32ncurses5-dev \
        lib32stdc++6 \
        lib32z1 \
        libtinfo5 \
        libc6 \
        zlib1g \
        libsdl2-2.0-0 \
        libcurl3-gnutls:i386 \
        wget \
        unzip \
    && apt clean \
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
        +quit \

    ## Create symlinks and appdata for Steam
    && mkdir -p ~/.steam/sdk32 \
    && ln -s $GAME_DIR/steamclient.so ~/.steam/sdk32/steamclient.so \
    && echo '10' > $GAME_DIR/steam_appid.txt

## Copy our run script into the image
COPY run.sh $APP_DIR/run.sh

## Set working directory
WORKDIR $APP_DIR

## Start the run script
CMD ["bash", "run.sh"]
