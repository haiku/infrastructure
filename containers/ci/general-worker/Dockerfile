FROM docker.io/debian:trixie-slim

MAINTAINER Haiku, Inc. <contact@haiku-os.org>
LABEL org.opencontainers.image.source https://github.com/haiku/infrastructure
LABEL org.opencontainers.image.url https://github.com/haiku/infrastructure/tree/master/containers/ci/general-worker
LABEL org.opencontainers.image.vendor Haiku, Inc.
LABEL org.opencontainers.image.description Base container for Haiku build automation.

USER root

RUN apt update && apt install -y --no-install-recommends \
  attr \
  autoconf \
  automake \
  bc \
  bison \
  byacc \
  build-essential \
  buildah \
  bzip2 \
  ca-certificates \
  coreutils \
  cmake \
  curl \
  device-tree-compiler \
  diffutils \
  file \
  flex \
  g++ \
  gawk \
  gcc \
  genisoimage \
  git \
  jq \
  less \
  libcurl4-openssl-dev \
  libtool \
  libssl-dev \
  make \
  minisign \
  mtools \
  nasm \
  ninja-build \
  python3 \
  sbsigntool \
  skopeo \
  tar \
  texinfo \
  u-boot-tools \
  util-linux \
  vim \
  zip \
  unzip \
  wget \
  xorriso \
  xz-utils \
  zlib1g-dev; \
  if [ "$(uname -m)" = "x86_64" ]; then apt install -y gcc-multilib; fi; \
  if [ "$(uname -m)" = "x86_64" ]; then wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc; fi; \
  if [ "$(uname -m)" = "aarch64" ]; then wget https://dl.min.io/client/mc/release/linux-arm64/mc -O /usr/local/bin/mc; fi; \
  chmod 755 /usr/local/bin/mc; \
  cd /tmp && \
  wget https://github.com/MestreLion/git-tools/archive/refs/tags/v2025.08.tar.gz -O /tmp/v2025.08.tar.gz && \
  tar xvf /tmp/v2025.08.tar.gz git-tools-2025.08/git-restore-mtime && \
  mv git-tools-2025.08/git-restore-mtime /usr/local/bin/ && chmod 755 /usr/local/bin/git-restore-mtime && \
  rm -rf /tmp/*

# We don't use this in our build pipelines. It's kinda big too.
#RUN git clone --depth 1 https://github.com/viveris/llvm-project.git &&\
#    cd llvm-project &&\
#    mkdir build &&\
#    cd build &&\
#    cmake -DCMAKE_BUILD_TYPE=MinSizeRel -DLLVM_ENABLE_PROJECTS=clang -G "Unix Makefiles" ../llvm &&\
#    make -j 2 clang-format &&\
#    cp ./bin/clang-format /usr/bin &&\
#    cp ../clang/tools/clang-format/git-clang-format /usr/bin &&\
#    cd ../../ &&\
#    rm -rf llvm-project/
