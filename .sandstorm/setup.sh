#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

#
# Configure sources and install packages
#
apt-get update
# we want to install some stuff from https sources
apt-get install -y apt-transport-https
# we want to install the latest RStudio
cat >> /etc/apt/sources.list <<EOF

# latest RStudio sources
deb https://cran.rstudio.com/bin/linux/debian jessie-cran3/

EOF
apt-get install -y --force-yes --no-install-recommends nginx r-base r-base-dev gdebi-core libcurl4-openssl-dev libssl-dev
# This part needs to be updated when a new version is avaiable
wget https://download2.rstudio.org/rstudio-server-0.99.892-amd64.deb
gdebi -n -q rstudio-server-0.99.892-amd64.deb
# Start command: $sudo /usr/lib/rstudio-server/bin/rserver

# RStudio Server Config
#cat > /etc/rstudio/rserver.conf <<EOF
## Server Configuration File
#www-address=127.0.0.1
#EOF
# Set up nginx config
cat >  /etc/nginx/sites-enabled/default <<EOF
http {
  map \$http_upgrade \$connection_upgrade {
      default upgrade;
      ''      close;
    }
  server {
      listen 8000 default_server;
      listen [::]:8000 default_server ipv6only=on;

      location / {
        proxy_pass http://localhost:8787;
        proxy_redirect http://localhost:8787/ \$scheme://\$host/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_read_timeout 20d;
      }
  }
}
EOF
service nginx stop
systemctl disable nginx
# patch nginx conf to not bother trying to setuid, since we're not root
sed --in-place='' \
        --expression 's/^user www-data/#user www-data/' \
        --expression 's#^pid /run/nginx.pid#pid /var/run/nginx.pid#' \
        --expression 's/^\s*error_log.*/error_log stderr;/' \
        --expression 's/^\s*access_log.*/access_log off;/' \
        /etc/nginx/nginx.conf

#
# Configuration of the system
#
# groupadd ruser
su -c "groupadd ruser"
# useradd ruser
su -c "useradd ruser -s /bin/bash -m -g ruser"
# passwd ruser
chpasswd << 'END'
ruser:ruser
END

#
# Install R packages
#

# RText Tools for classification
su - -c "R -e \"install.packages('RTextTools', repos='http://cran.rstudio.com/')\""

# deepnet: deep learning toolkit in R
su - -c "R -e \"install.packages('deepnet', repos='http://cran.rstudio.com/')\""

# Install Shiny in system-wide library
# su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
# R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"

# Bye bye
exit 0
