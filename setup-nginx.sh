

sudo docker run -d \
  -p 80:80 \
  -p 443:443 \
  --name nginx \
  -v /etc/nginx/conf.d \
  -v /etc/nginx/vhost.d \
  -v /usr/share/nginx/html \
  -v /etc/nginx/certs \    
  --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
  nginx

sudo docker run -d \
  --name nginx-gen \
  --volumes-from nginx     \
  -v /data/dockergen/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
  -v /var/run/docker.sock:/tmp/docker.sock:ro \
  --label com.github.jrcs.letsencrypt_nginx_proxy_companion.docker_gen \
  jwilder/docker-gen  \
  -notify-sighup nginx -watch -wait 5s:30s \
  /etc/docker-gen/templates/nginx.tmpl \
  /etc/nginx/conf.d/default.conf


sudo docker run -d \
  --name nginx-letsencrypt \
  --volumes-from nginx \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  jrcs/letsencrypt-nginx-proxy-companion

# run portainer for administration
sudo docker volume create portainer_data
sudo docker run -d \
  --name portainer \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  -e VIRTUAL_HOST=admin.schnuppmann.de \
  -e LETSENCRYPT_HOST=<DOMAIN> \
  -e LETSENCRYPT_EMAIL=<EMAIL> \
  portainer/portainer