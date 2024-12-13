FROM debian:bookworm-slim
LABEL maintainer="cunneen"
RUN echo "Previous builds:"
RUN [ -f build-log.txt ] && cat build-log.txt || echo "none"
RUN echo "========================================================" | tee -a build-log.txt
RUN echo "build started at $(date +%Y-%m-%d-%H-%M-%S)" | tee -a build-log.txt
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked <<EOT
  rm -f /etc/apt/apt.conf.d/docker-clean
  apt-get update
  apt-get install -y \
    git \
    curl \
    make \
    gcc \
    gcc-11 \
    g++ \
    g++-11 \
    bzip2 \
    ca-certificates \
    --no-install-recommends
EOT

# Use g++ v11 and gcc v11
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 11
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11
RUN update-alternatives --install /usr/bin/cc  cc  /usr/bin/gcc-11 11
RUN update-alternatives --remove-all cpp
RUN update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-11 11
RUN update-alternatives --set g++ $(update-alternatives --list g++ | grep g++-11)
RUN update-alternatives --set gcc $(update-alternatives --list gcc | grep gcc-11)
RUN update-alternatives --set cc $(update-alternatives --list cc | grep gcc-11)
RUN update-alternatives --set cpp $(update-alternatives --list cpp | grep cpp-11)

RUN useradd --create-home --shell /bin/bash --uid 1000 --user-group app

RUN <<EOT
  mkdir /built_app
  mkdir /bundle
  chown -R app:app /home/app/
  chown -R app:app /built_app
  chown -R app:app /bundle
  chmod 770 /built_app
  chmod 770 /bundle
EOT

# Install python 3.9 from debian bullseye (i.e. oldstable)
# We need python < 3.11 or node-gyp fails on meteor/node14 on ARM

# Add oldstable (bullseye) repositories so we can install python 3.9
COPY <<EOF /etc/apt/sources.list.d/zzz-debian-old-packages.list
deb http://deb.debian.org/debian oldstable main
deb http://deb.debian.org/debian oldstable-updates main
EOF

# Read the apt repo metadata for the old packages
RUN apt-get update
# Install python 3.9 packages, pinning the version numbers
RUN <<EOT
  apt-get install -y \
    python3-venv=3.9.2-3 \
    python3=3.9.2-3 \
    python3-distutils=3.9.2-1 \
    python3-minimal=3.9.2-3 \
    libpython3-stdlib=3.9.2-3 \
    python3-lib2to3=3.9.2-1
EOT

RUN echo Install Pyenv:
ENV PYENV_ROOT="/opt/pyenv"
ENV PATH="${PYENV_ROOT}/bin:$PATH"

RUN curl https://pyenv.run | bash ;

# add pyenv to .bashrc for root and the app user
RUN echo "export PYENV_ROOT='${PYENV_ROOT}'" >> /root/.bashrc
RUN echo "export PYENV_ROOT='${PYENV_ROOT}'" >> /home/app/.bashrc
RUN echo 'export PATH="${PYENV_ROOT}/bin:$PATH"' >> /root/.bashrc
RUN echo 'export PATH="${PYENV_ROOT}/bin:$PATH"' >> /home/app/.bashrc
RUN chown app:app /home/app/.bashrc

# Remove apt packages that we no longer need
# i.e. everything we added ourselves except:   
#  curl python/python3 make g++-11 bzip2 ca-certificates 
RUN <<EOT
apt-get purge -y \
    git 
EOT

RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER app
WORKDIR /home/app
RUN mkdir scripts && mkdir setup
COPY --chown=app:app ./setup ./setup
RUN bash setup/install_nvm.sh

COPY --chown=app:app ./scripts ./scripts

ONBUILD USER app
ONBUILD ARG NODE_VERSION='8.17.0'
ONBUILD ARG EXACT_NODE_VERSION=false
ONBUILD RUN bash ./scripts/onbuild-node.sh
ONBUILD ENV NODE_PATH=/home/app/.onbuild-node/lib/node_modules PATH=/home/app/.onbuild-node/bin:$PATH

USER root
RUN bash setup/setup_root_nvm.sh
EXPOSE 3000
ENTRYPOINT bash /home/app/scripts/entry.sh
