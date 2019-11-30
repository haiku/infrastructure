FROM buildbot/buildbot-worker

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  bc \
  bison \
  bzip2 \
  ca-certificates \
  cmake \
  curl \
  device-tree-compiler \
  file \
  flex \
  g++ \
  gawk \
  genisoimage \
  git \
  libcurl4-openssl-dev \
  libssl-dev \
  make \
  mtools \
  nasm \
  ninja-build \
  python \
  texinfo \
  u-boot-tools \
  util-linux \
  vim \
  wget \
  xz-utils \
  zlib1g-dev

USER buildbot
