FROM 42wim/matterbridge

ARG DOMAINNAME
ARG CHANNEL
ARG XMPP_USER
ARG XMPP_PASS
ARG TELEGRAM_TOKEN 
ARG TELEGRAM_CHANNEL 

COPY matterbridge.toml /matterbridge.toml

RUN sed -i "s/<DOMAINNAME>/$DOMAINNAME/g" /matterbridge.toml
RUN sed -i "s/<CHANNEL>/$CHANNEL/g" /matterbridge.toml
RUN sed -i "s/<TELEGRAM_TOKEN>/$TELEGRAM_TOKEN/g" /matterbridge.toml
RUN sed -i "s/<TELEGRAM_CHANNEL>/$TELEGRAM_CHANNEL/g" /matterbridge.toml
RUN sed -i "s/<XMPP_USER>/$XMPP_USER/g" /matterbridge.toml
RUN sed -i "s/<XMPP_PASS>/$XMPP_PASS/g" /matterbridge.toml

ENTRYPOINT ["/bin/matterbridge"]
