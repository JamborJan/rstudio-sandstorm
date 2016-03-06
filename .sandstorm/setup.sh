#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail

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
apt-get install -y --force-yes --no-install-recommends r-base r-base-dev gdebi-core libcurl4-openssl-dev libssl-dev
# This part needs to be updated when a new version is avaiable
wget https://download2.rstudio.org/rstudio-server-0.99.892-amd64.deb
gdebi -n -q rstudio-server-0.99.892-amd64.deb
# Start command: $sudo /usr/lib/rstudio-server/bin/rserver

# RStudio Server Config
#cat > /etc/rstudio/rserver.conf <<EOF
## Server Configuration File
#www-address=127.0.0.1
#EOF

#
# Install Shiny Server (Ubuntu only)
# This will install Shiny Server into /opt/shiny-server/
#
wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.4.2.786-amd64.deb
gdebi -n -q shiny-server-1.4.2.786-amd64.deb

# Set up Shiny Server config
cat > /etc/shiny-server/shiny-server.conf <<EOF
# Instruct Shiny Server to run applications as the user "shiny"
run_as shiny;

# Define a server that listens on port 8000
server {
  listen 8000;

  # Define a location at the base URL
  location / {

    # Host the directory of Shiny Apps stored in this directory
    site_dir /var/shiny-server;

    # Log all Shiny output to files in this directory
    log_dir /var/log/shiny-server;

    # When a user visits the base URL rather than a particular application,
    # an index of the applications available in this directory will be shown.
    directory_index on;
  }
}
EOF

#
# Configuration of the system
#

# adjust Shiny Server config
#sed --in-place='' \
#        --expression 's#^site_dir /var/shiny-server#site_dir /var/shiny-server#' \
#        --expression 's#^site_dir /var/shiny-server#site_dir /var/shiny-server#' \
#        --expression 's#^log_dir /var/log/shiny-server#log_dir /var/log/shiny-server#' \
#        /etc/shiny-server/shiny-server.conf

# Add user for the R Server, we can remove this when the app is done
# groupadd ruser
su -c "groupadd ruser"
# useradd ruser
su -c "useradd ruser -s /bin/bash -m -g ruser"
# passwd ruser
chpasswd << 'END'
ruser:ruser
END

#
# Stop and disable server as we need to run them
# when the app launches
#

# Stop RStudio Server
rstudio-server stop
# Stop Shiny Server
service shiny-server stop

# Bye bye
exit 0
