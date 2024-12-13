set -e
export NVM_DIR="/home/app/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]
. "$NVM_DIR/nvm.sh"
# download source for custom ARM nodejs 14 binary build
DOWNLOAD_BASE_URL="https://public.juto.com.au/node"
NODE_VERSION="$(node /home/app/scripts/node-version.js)"
# Replace a possible 'v' prefix
NODE_VERSION="$(echo $NODE_VERSION | sed 's/^v//')"
echo "NODE_VERSION=$NODE_VERSION"

if [[ $DEBUG_NODE_VERSION == "0" ]]; then
  cat /home/app/scripts/log.txt || true
fi

MAJOR_NODE_VERSION=`echo $NODE_VERSION | awk -F. '{print $1}'`
MINOR_NODE_VERSION=`echo $NODE_VERSION | awk -F. '{print $2}'`
PATCH_NODE_VERSION=`echo $NODE_VERSION | awk -F. '{print $3}'`

echo "Node: $NODE_VERSION (parsed: $MAJOR_NODE_VERSION.$MINOR_NODE_VERSION.$PATCH_NODE_VERSION)"

ARCH="$(uname -m)"
echo "ARCH=$ARCH"

if [[ $MAJOR_NODE_VERSION == "14" ]]; then
  if [[ $ARCH == "aarch64" ]]; then # Ignore minor version as we currently only have v14.21.4 for arm64
    NODE_VERSION="14.21.4"
    MAJOR_NODE_VERSION="14"
    MINOR_NODE_VERSION="21"
    PATCH_NODE_VERSION="4"
    NODE_HEADERS_FILENAME="node-v$NODE_VERSION-headers.tar.gz"
    if [ ! -f "/home/app/$NODE_HEADERS_FILENAME" ]; then
      echo "Downloading node headers for cunneen's NodeJS v14 fork (for node-gyp usage)..."
      NODE_HEADERS_DOWNLOAD_URL="$DOWNLOAD_BASE_URL/v$NODE_VERSION/$NODE_HEADERS_FILENAME"
      echo "Downloading Headers from $NODE_HEADERS_DOWNLOAD_URL:"
      curl -L "${NODE_HEADERS_DOWNLOAD_URL}" -o "/home/app/$NODE_HEADERS_FILENAME"
    fi
    echo "setting npm_config_tarball to /home/app/$NODE_HEADERS_FILENAME"
    export npm_config_tarball="/home/app/$NODE_HEADERS_FILENAME"
  fi

  NODE_INSTALL_PATH="/home/app/.nvm/versions/node/v$NODE_VERSION"

  if [ -d $NODE_INSTALL_PATH ]; then # Node is already installed
    echo "Meteor's custom v14 LTS Node version is already installed ($NODE_VERSION)"
  else
    # For ARM / AARCH64, if the meteor major version is 14, we'll use v14.21.4
    if [[ $ARCH == "aarch64" ]]; then # Ignore minor version as we currently only have v14.21.4 for arm64
      echo "Trying cunneen's fork of Meteor's custom NodeJS v14 LTS version"
      NODE_DOWNLOAD_FOLDERNAME="node-v${NODE_VERSION}-linux-arm64"
      NODE_DOWNLOAD_URL="$DOWNLOAD_BASE_URL/v${NODE_VERSION}/${NODE_DOWNLOAD_FOLDERNAME}.tar.gz"
      echo "Downloading $NODE_DOWNLOAD_URL:"
      curl -L "${NODE_DOWNLOAD_URL}" | tar xzf - -C /tmp/
      mv -T /tmp/${NODE_DOWNLOAD_FOLDERNAME} $NODE_INSTALL_PATH;
      nvm use $NODE_VERSION
      echo "=> Installing node-gyp v9 globally via 'npm i -g node-gyp@9'"
      npm install -g node-gyp@9
    elif [[ $MINOR_NODE_VERSION -ge 21 && $PATCH_NODE_VERSION -ge 4 ]]; then

      echo "Using Meteor's custom NodeJS v14 LTS version"
      # https://hub.docker.com/layers/meteor/node/14.21.4/images/sha256-f4e19b4169ff617118f78866c2ffe392a7ef44d4e30f2f9fc31eef2c35ceebf3?context=explore
      curl "https://static.meteor.com/dev-bundle-node-os/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" | tar xzf - -C /tmp/
      mv /tmp/node-v$NODE_VERSION-linux-x64 $NODE_INSTALL_PATH
    else
      echo "Node version $NODE_VERSION requested"
    fi
  fi
  nvm use $NODE_VERSION
else
  echo "Using NVM"
  nvm install $NODE_VERSION
fi

nvm alias default $NODE_VERSION
export NODE_PATH=$(dirname $(nvm which $(node --version)))
