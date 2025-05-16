FROM        steamcmd/steamcmd:latest

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt update && \
            apt upgrade -y && \
            apt dist-upgrade -y && \
            apt install -y curl && \
            apt autoremove -y && \
            apt autoclean -y

RUN         steamcmd \
            +force_install_dir /srv/avorion \
            +login anonymous \
            +app_update 565060 validate \
            +quit

EXPOSE      27000/tcp
EXPOSE      27000/udp
EXPOSE      27003/udp
EXPOSE      27020/udp
EXPOSE      27021/udp

VOLUME      /root/.avorion
WORKDIR     /srv/avorion

COPY        init /srv/avorion/init
COPY        entrypoint.sh /srv/avorion/entrypoint.sh
COPY        healthcheck.sh /srv/avorion/healthcheck.sh
RUN         chmod +x /srv/avorion/entrypoint.sh /srv/avorion/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD /srv/avorion/healthcheck.sh

ENTRYPOINT  [ "/srv/avorion/entrypoint.sh" ]