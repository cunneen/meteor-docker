#!/bin/sh
set -e

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

export NVM_DIR="/home/app/.nvm" 
[ -s "$NVM_DIR/nvm.sh" ] 
. "$NVM_DIR/nvm.sh"

# initial version used during setup
nvm install 16

node /home/app/setup/install_node.js

DEFAULT_VERSION="$(node /home/app/setup/default_node.js)"
nvm alias default $DEFAULT_VERSION
nvm use $DEFAULT_VERSION

nvm uninstall 16
nvm cache clear
