FROM        steamcmd/steamcmd:latest

ARG         SESSION_NAME
ARG         SERVER_MAP
ARG         SERVER_PASSWORD
ARG         ADMIN_PASSWORD
ARG         MAX_PLAYERS
ARG         UPDATE_ON_START
ARG         BACKUP_ON_STOP
ARG         PRE_UPDATE_BACKUP
ARG         WARN_ON_STOP
ARG         ENABLE_CROSSPLAY
ARG         DISABLE_BATTLEYE
ARG         ARK_SERVER_VOLUME
ARG         GAME_CLIENT_PORT
ARG         UDP_SOCKET_PORT
ARG         SERVER_LIST_PORT
ARG         RCON_PORT
ARG         GAME_MOD_IDS

ENV         DEBIAN_FRONTEND=noninteractive \
            SESSION_NAME=${SESSION_NAME} \
            SERVER_MAP=${SERVER_MAP} \
            SERVER_PASSWORD=${SERVER_PASSWORD} \
            ADMIN_PASSWORD=${ADMIN_PASSWORD} \
            MAX_PLAYERS=${MAX_PLAYERS} \
            UPDATE_ON_START=${UPDATE_ON_START} \
            BACKUP_ON_STOP=${BACKUP_ON_STOP} \
            PRE_UPDATE_BACKUP=${PRE_UPDATE_BACKUP} \
            WARN_ON_STOP=${WARN_ON_STOP} \
            ENABLE_CROSSPLAY=${ENABLE_CROSSPLAY} \
            DISABLE_BATTLEYE=${DISABLE_BATTLEYE} \
            ARK_SERVER_VOLUME=${ARK_SERVER_VOLUME} \
            GAME_CLIENT_PORT=${GAME_CLIENT_PORT} \
            UDP_SOCKET_PORT=${UDP_SOCKET_PORT} \
            RCON_PORT=${RCON_PORT} \
            SERVER_LIST_PORT=${SERVER_LIST_PORT} \
            GAME_MOD_IDS=${GAME_MOD_IDS} \
            TEMPLATE_DIRECTORY=/conf.d \
            ARK_TOOLS_DIR=${ARK_SERVER_VOLUME}/arkmanager \
            BIN_DIR=/bin/ \
            STEAM_USER=steam \
            STEAM_HOME=/home/steam \
            STEAM_LOGIN=anonymous

RUN         set -x && \
            apt update && \
            apt upgrade -y && \
            apt dist-upgrade -y && \
            apt install -y perl-modules curl lsof libc6-i386 lib32gcc-s1 bzip2 cron gosu && \
            useradd -m -d ${STEAM_HOME} -s /bin/bash ${STEAM_USER} && \
            curl -sL https://raw.githubusercontent.com/arkmanager/ark-server-tools/master/netinstall.sh | bash -s ${STEAM_USER} --install-service && \
            apt autoremove -y && \
            apt autoclean -y && \
            rm -rf /tmp/* /var/cache/*

COPY        bin/*    ${BIN_DIR}
COPY        conf.d   ${TEMPLATE_DIRECTORY}

RUN         chown -R ${STEAM_USER}:${STEAM_USER} ${BIN_DIR} && \
            chown -R ${STEAM_USER}:${STEAM_USER} ${TEMPLATE_DIRECTORY} && \
            chmod +x ${BIN_DIR}docker-entrypoint.sh ${BIN_DIR}steam-entrypoint.sh

RUN         steamcmd +quit

EXPOSE      ${GAME_CLIENT_PORT}/udp
EXPOSE      ${UDP_SOCKET_PORT}/udp
EXPOSE      ${SERVER_LIST_PORT}/udp
EXPOSE      ${RCON_PORT}/tcp

VOLUME      ${ARK_SERVER_VOLUME}
WORKDIR     ${ARK_SERVER_VOLUME}

ENTRYPOINT  [ "/bin/docker-entrypoint.sh" ]
CMD         []