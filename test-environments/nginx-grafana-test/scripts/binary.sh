#!/bin/bash

# set Grafana version
GF_VERSION="8.3.4"

# make sure we are home
cd /home/grafana || return

# install packages
sudo apt-get update -y
sudo apt-get install -y wget tmux nginx

# open port 80 for unencrypted web traffic
# sudo ufw allow 'Nginx HTTP'

# add the grafana-nginx server block using a heredoc
sudo tee /etc/nginx/sites-available/grafana-nginx > /dev/null << 'EOF'
# this is required to proxy Grafana Live WebSocket connections.
map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}

server {
  listen 80;
  root /usr/share/nginx/html;
  index index.html index.htm;

  location / {
    proxy_pass http://localhost:3000/;
  }

  # Proxy Grafana Live WebSocket connections.
  location /api/live {
    rewrite  ^/(.*)  /$1 break;
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
cd grafana-"${GF_VERSION}" || exit

# start binary in detached tmux session
tmux new -d -s grafanaBinary
tmux send-keys -t grafanaBinary.0 "./bin/grafana-server" ENTER
