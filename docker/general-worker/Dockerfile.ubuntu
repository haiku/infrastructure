FROM ubuntu

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  bc \
  bison \
  build-essential \
  bzip2 \
  ca-certificates \
  cmake \
  curl \
  device-tree-compiler \
  file \
  flex \
  gcc-multilib \
  g++ \
  gawk \
  genisoimage \
  git \
  less \
  libcurl4-openssl-dev \
  libtool \
  libssl-dev \
  make \
  mtools \
  nasm \
  ninja-build \
  python \
  python3 \
  texinfo \
  u-boot-tools \
  util-linux \
  vim \
  zip \
  unzip \
  wget \
  xorriso \
  xz-utils \
  zlib1g-dev

ADD https://dl.min.io/client/mc/release/linux-amd64/mc /usr/local/bin/mc
RUN chmod 755 /usr/local/bin/mc
