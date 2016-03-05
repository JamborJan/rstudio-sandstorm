RStudio for Sandstorm
=====================

The package is done with [vagrant-spk](https://github.com/sandstorm-io/vagrant-spk), a tool designed to help app developers package apps for [Sandstorm](https://sandstorm.io).

You can follow the following steps to make your own package or to contribute.

## Prerequisites

You will need to install:
- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Git

## Step by Step

    git clone https://github.com/sandstorm-io/vagrant-spk
    git clone https://github.com/JamborJan/rstudio-sandstorm
    export PATH=$(pwd)/vagrant-spk:$PATH
    cd rstudio-sandstorm
    vagrant-spk up
    vagrant-spk dev

Then visit [http://localhost:8787](http://localhost:8787/) in a web browser. At the moment you need to login with:

    login: ruser
    password: ruser

This version of the app is not yet usable via [http://local.sandstorm.io:6080/](http://local.sandstorm.io:6080/).

Note: when you want to fork this repo and create actual app packages for the app store you would need either the original app key or create a new one and make your own app.
