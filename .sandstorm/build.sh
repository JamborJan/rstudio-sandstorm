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
# Install some test data for Shiny Server and load it
#
su - -c "R -e \"library('shiny', lib.loc='/usr/local/lib/R/site-library')\""
# Markdown Support
su - -c "R -e \"install.packages('rmarkdown', repos='http://cran.rstudio.com/')\""
# Simple Hello Shiny App
su - -c "R -e \"shiny::runGitHub('shiny-examples', 'rstudio', subdir = '001-hello')\""
# The Shiny Server will listen on http://127.0.0.1:3174


# By default, this script does nothing.  You'll have to modify it as
# appropriate for your application.
cd /opt/app
exit 0
