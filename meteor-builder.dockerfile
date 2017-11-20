FROM alpine
RUN apk update && apk add curl git
RUN curl https://install.meteor.com/ | sh

ENTRYPOINT [ "meteor-builder.sh" ]
