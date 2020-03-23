FROM fedora:latest

USER root

RUN dnf install -y \
  attr \
  autoconf \
  automake \
  bc \
  bison \
  byacc \
  bzip2 \
  cmake \
  curl \
  curl-devel \
  diffutils \
  flex \
  gcc \
  gcc-c++ \
  git \
  glibc-devel \
  glibc-devel.i686 \
  libstdc++ \
  libstdc++-static \
  libstdc++-devel.x86_64 \
  libstdc++-devel.i686 \
  libtool \
  libfdt \
  make \
  minisign \
  mtools \
  nasm \
  ninja-build \
  python3 \
  python3-devel \
  swig \
  texinfo \
  vim \
  uboot-tools \
  unzip \
  wget \
  zip \
  xorriso \
  xz \
  zlib \
  zlib-devel

ADD https://dl.min.io/client/mc/release/linux-amd64/mc /usr/local/bin/mc
RUN chmod 755 /usr/local/bin/mc
