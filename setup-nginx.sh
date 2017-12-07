#!/bin/bash

DOMAINNAME="$1"
EMAIL="$2"

if [[ -z "$DOMAINNAME" ]]; then
  echo "Usage: setup.sh <DOMAINNAME> <LETSENCRYPT EMAIL>"
  exit
fi

if [[ -z "$EMAIL" ]]; then
  echo "Usage: setup.sh <DOMAINNAME> <LETSENCRYPT EMAIL>"
  exit
fi

echo "ensure directories"
if [ ! -d "/data/configs" ]; then
  mkdir /data
  mkdir /data/configs
fi

echo "copy configuration"
cp prosody.cfg.lua /data/configs
sed -i "s/<DOMAINNAME>/$DOMAINNAME/g" /data/configs/prosody.cfg.lua
sed -i "s/<EMAIL>/$EMAIL/g" /data/configs/prosody.cfg.lua
cp nginx.tmpl /data/configs

echo "create docker volumes"
docker volume create portainer_data
docker volume create nginx_certs
docker volume create nginx_conf
docker volume create nginx_vhost
docker volume create nginx_html

echo "stop and remove containers"
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

echo "create and run containers"
docker run -d \
  -p 80:80 \
  -p 443:443 \
  --name nginx \
  -v nginx_conf:/etc/nginx/conf.d \
  -v nginx_vhost:/etc/nginx/vhost.d \
  -v nginx_html:/usr/share/nginx/html \
  -v nginx_certs:/etc/nginx/certs \
  --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
  nginx

sleep 10

docker run -d \
  --name nginx-gen \
  --volumes-from nginx     \
  -v /data/configs/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
  -v /var/run/docker.sock:/tmp/docker.sock:ro \
  --label com.github.jrcs.letsencrypt_nginx_proxy_companion.docker_gen \
  jwilder/docker-gen  \
  -notify-sighup nginx -watch -wait 5s:30s \
  /etc/docker-gen/templates/nginx.tmpl \
  /etc/nginx/conf.d/default.conf

sleep 10

docker run -d \
  --name nginx-letsencrypt \
  --volumes-from nginx \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  jrcs/letsencrypt-nginx-proxy-companion

sleep 5

# run portainer for administration
docker run -d \
  --name portainer \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  -e VIRTUAL_HOST=admin.$DOMAINNAME \
  -e LETSENCRYPT_HOST=admin.$DOMAINNAME \
  -e LETSENCRYPT_EMAIL=$EMAIL \
  portainer/portainer

sleep 5


echo "setup prosody"
if [ ! -d "/data/prosody" ]; then
  mkdir /data/prosody
fi
# change user to prosody user
chown 102:106 /data/prosody

docker run -d \
  --name prosody \
  -v nginx_certs:/etc/prosody/certs:ro \
  -v /data/prosody:/data \
  -v /data/configs/prosody.cfg.lua:/etc/prosody/prosody.cfg.lua \
  -e VIRTUAL_HOST=$DOMAINNAME \
  -e VIRTUAL_PORT=5280 \
  -e LETSENCRYPT_HOST=$DOMAINNAME \
  -e LETSENCRYPT_EMAIL=$EMAIL \
  -p 5222:5222 \
  prosody/prosody


#docker run -d \
#  --name app \
#  --link mongodb:mongodb \
#  -e VIRTUAL_HOST=app.$DOMAINNAME \
#  -e LETSENCRYPT_HOST=app.$DOMAINNAME \
#  -e LETSENCRYPT_EMAIL=$email \
#  -e MONGO_URL=mongodb://mongodb:27017 \
#  -e ROOT_URL=https://app.$DOMAINNAME \
#  lwo/meteor-builder  
