FROM          steamcmd/steamcmd:debian

ENV           DEBIAN_FRONTEND=noninteractive

RUN           apt-get update && \
              apt-get upgrade --yes && \
              apt-get dist-upgrade --yes && \
              apt-get autoremove --yes && \
              apt-get autoclean --yes && \
              apt-get clean --yes
RUN           apt-get install lib32gcc-s1 xmlstarlet --yes

EXPOSE        2302/udp
EXPOSE        2303/udp
EXPOSE        2304/udp
EXPOSE        2305/udp
EXPOSE        8766/udp
EXPOSE        27016/udp

WORKDIR       /root

COPY          entrypoint.sh /root/entrypoint.sh
RUN           chmod +x /root/entrypoint.sh

CMD           [ "start" ]
ENTRYPOINT    [ "/root/entrypoint.sh" ]
