#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail
# export DEBIAN_FRONTEND=noninteractive

#
# Configure sources and install packages
#
apt-get update
# we want to install some stuff from https sources
apt-get install -y apt-transport-https
# we want to install the latest RStudio
cat >> /etc/apt/sources.list <<EOF

# latest RStudio sources
# deb https://cran.rstudio.com/bin/linux/debian jessie-cran3/
deb https://cran.rstudio.com/bin/linux/ubuntu trusty/

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

#
# Install R packages
#

# RText Tools for classification
su - -c "R -e \"install.packages('RTextTools', repos='http://cran.rstudio.com/')\""

# deepnet: deep learning toolkit in R
su - -c "R -e \"install.packages('deepnet', repos='http://cran.rstudio.com/')\""

# Install Shiny in system-wide library
su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""

#
# Install Shiny Server (Ubuntu only)
# This will install Shiny Server into /opt/shiny-server/
#
wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.4.2.786-amd64.deb
gdebi -n -q shiny-server-1.4.2.786-amd64.deb

#
# When we run on Debian we have to build Shiny Server
#
#cd /opt
#git clone https://github.com/rstudio/shiny-server.git
# Get into a temporary directory in which we'll build the project
#cd shiny-server
#mkdir tmp
#cd tmp
# Add the bin directory to the path so we can reference node
#DIR=`pwd`
#PATH=$DIR/../bin:$PATH
# See the "Python" section below if your default python version is not 2.6 or 2.7.
#PYTHON=`which python`
# Use cmake to prepare the make step
#cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DPYTHON="$PYTHON" ../
# Recompile the npm modules included in the project
#make
#mkdir ../build
#
# Hier ist ein Problem mit den Berechtigungen in
#(cd .. && ./bin/npm --python="$PYTHON" rebuild)
# Need to rebuild our gyp bindings since 'npm rebuild' won't run gyp for us.
#(cd .. && ./bin/node ./ext/node/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js --python="$PYTHON" rebuild)
# Install the software at the predefined location
#sudo make install

#
# Stop and disable server as we need ti run them
#

# Stop and disable autostart for nginx
service nginx stop
update-rc.d -f nginx disable
# Stop RStudio Server
rstudio-server stop
# Stop Shiny Server
service shiny-server stop


#
# Configuration of the system
#

# patch nginx conf to not bother trying to setuid, since we're not root
sed --in-place='' \
        --expression 's/^user www-data/#user www-data/' \
        --expression 's#^pid /run/nginx.pid#pid /var/run/nginx.pid#' \
        --expression 's/^\s*error_log.*/error_log stderr;/' \
        --expression 's/^\s*access_log.*/access_log off;/' \
        /etc/nginx/nginx.conf

# adjust Shiny Server config
sed --in-place='' \
        --expression 's#^site_dir /var/shiny-server#site_dir /var/shiny-server#' \
        --expression 's#^log_dir /var/log/shiny-server#log_dir /var/log/shiny-server#' \
        /etc/shiny-server/shiny-server.conf

# Add user for the R Server
# groupadd ruser
su -c "groupadd ruser"
# useradd ruser
su -c "useradd ruser -s /bin/bash -m -g ruser"
# passwd ruser
chpasswd << 'END'
ruser:ruser
END

# Bye bye
exit 0
