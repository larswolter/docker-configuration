FROM matrixdotorg/synapse:latest

ARG DOMAINNAME

RUN mkdir /config
COPY synapse.yaml /config/synapse.yaml
COPY synapse.log.config /config/synapse.log.config
USER root
RUN sed -i "s/<DOMAINNAME>/$DOMAINNAME/g" /config/synapse.yaml
RUN sed -i "s/<DOMAINNAME>/$DOMAINNAME/g" /config/synapse.log.config
