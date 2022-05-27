FROM prosody/prosody

ARG DOMAINNAME

COPY prosody.cfg.lua /etc/prosody/prosody.cfg.lua
USER root
RUN sed -i "s/<DOMAINNAME>/$DOMAINNAME/g" /etc/prosody/prosody.cfg.lua
