#!/bin/bash
set -euo pipefail
# This script is run in the VM each time you run `vagrant-spk dev`.  This is
# the ideal place to invoke anything which is normally part of your app's build
# process - transforming the code in your repository into the collection of files
# which can actually run the service in production
#
# Some examples:
#
#   * For a C/C++ application, calling
#       ./configure && make && make install
#   * For a Python application, creating a virtualenv and installing
#     app-specific package dependencies:
#       virtualenv /opt/app/env
#       /opt/app/env/bin/pip install -r /opt/app/requirements.txt
#   * Building static assets from .less or .sass, or bundle and minify JS
#   * Collecting various build artifacts or assets into a deployment-ready
#     directory structure

#
# Install R packages
#

# Install Shiny in system-wide library
#sudo R -e "install.packages('shiny', destdir='/usr/local/lib/R/site-library/shiny/examples/01_hello', repos='http://cran.rstudio.com/')"
sudo R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"

# RText Tools for classification
sudo R -e "install.packages('RTextTools', repos='http://cran.rstudio.com/')"
#sudo R -e "library('RTextTools', lib.loc='/usr/local/lib/R/site-library')"

# deepnet: deep learning toolkit in R
sudo R -e "install.packages('deepnet', repos='http://cran.rstudio.com/')"
#sudo R -e "library('deepnet', lib.loc='/usr/local/lib/R/site-library')"

#
# Install some test data for Shiny Server and load it
#
# Load Shiny
R -e "library('shiny', lib.loc='/usr/local/lib/R/site-library')"
# Markdown Support
sudo R -e "install.packages('rmarkdown', repos='http://cran.rstudio.com/')"

# By default, this script does nothing.  You'll have to modify it as
# appropriate for your application.
cd /opt/app
exit 0
