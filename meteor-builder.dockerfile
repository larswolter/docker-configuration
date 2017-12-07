FROM debian:jessie as builder
RUN apt-get update && apt-get install -y curl git python build-essential
RUN curl https://install.meteor.com/ | sh

# Base image done, pulling sources for build
ARG REPOSITORY=undefined
ENV METEOR_ALLOW_SUPERUSER 1
RUN mkdir /build
WORKDIR /build
RUN git clone $REPOSITORY appsrc && cd appsrc && git submodule update --init

# Building meteor application
RUN cd appsrc && meteor npm install --production
RUN cd appsrc && meteor build --directory ../bundle


# preparation stage gets all packages for the final image
# needs build tools for that
FROM mhart/alpine-node as preparation
RUN apk update && apk add python make g++
RUN mkdir /app
WORKDIR /app
COPY --from=builder /build/bundle/bundle /app
RUN cd programs/server && npm install --production

# final stage for running the container, only needs node
FROM mhart/alpine-node as final 
RUN apk update && apk add glib \ 
  zlib libxml2 glib gobject-introspection \
  libjpeg-turbo libexif lcms2 fftw giflib libpng libpng \
  libwebp orc tiff poppler-glib librsvg libgsf openexr \ 
  libwebp \
  libexif \
  libxml2 \
  musl \
  libjpeg-turbo

ENV MONGO_URL mongodb://mongodb:27017
ENV ROOT_URL ${VIRTUAL_HOST}
ENV PORT 8080

RUN mkdir /app
COPY --from=preparation /app /app
WORKDIR /app
EXPOSE 8080

ENTRYPOINT [ "node", "main.js" ]
