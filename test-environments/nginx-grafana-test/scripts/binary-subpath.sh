#!/bin/bash

# set Grafana version
GF_VERSION="8.3.4"

# make sure we are home
cd /home/grafana || return

# install packages
sudo apt-get update -y
sudo apt-get install -y wget tmux nginx

# add the grafana-nginx server block using a heredoc
sudo tee /etc/nginx/sites-available/grafana-nginx > /dev/null << 'EOF'
# this is required to proxy Grafana Live WebSocket connections.
map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}

server {
  listen 80;
  root /usr/share/nginx/www;
  index index.html index.htm;

  location /grafana/ {
   proxy_pass http://localhost:3000/;
  }

  # Proxy Grafana Live WebSocket connections.
  location /grafana/api/live {
    rewrite  ^/grafana/(.*)  /$1 break;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_set_header Host $http_host;
    proxy_pass http://localhost:3000/;
  }
}
EOF

# symlink the new nginx config and remove default config
sudo ln -s /etc/nginx/sites-available/grafana-nginx /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# restart nginx service
sudo systemctl restart nginx

# get standalone binary
wget https://dl.grafana.com/oss/release/grafana-"${GF_VERSION}".linux-amd64.tar.gz
tar -zxvf grafana-"${GF_VERSION}".linux-amd64.tar.gz

# adjust grafana config to serve from sub-path
sed -i 's/^;root_url.*$/root_url = %(protocol)s:\/\/%(domain)s:%(http_port)s\/grafana\//g' /home/grafana/grafana-"${GF_VERSION}"/conf/sample.ini
sed -i 's/^;serve_from_sub_path.*$/serve_from_sub_path = true/g' /home/grafana/grafana-"${GF_VERSION}"/conf/sample.ini

# rename modified sample.ini as custom.ini
cp /home/grafana/grafana-"${GF_VERSION}"/conf/sample.ini /home/grafana/grafana-"${GF_VERSION}"/conf/custom.ini

# start binary in detached tmux session
cd grafana-"${GF_VERSION}" || exit
tmux new -d -s grafanaBinary
tmux send-keys -t grafanaBinary.0 "./bin/grafana-server" ENTER
