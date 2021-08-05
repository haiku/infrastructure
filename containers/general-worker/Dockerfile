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
  jq \
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

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN git clone --depth 1 https://github.com/viveris/llvm-project.git &&\
    cd llvm-project &&\
    mkdir build &&\
    cd build &&\
    cmake -DCMAKE_BUILD_TYPE=MinSizeRel -DLLVM_ENABLE_PROJECTS=clang -G "Unix Makefiles" ../llvm &&\
    make -j 2 clang-format &&\
    cp ./bin/clang-format /usr/bin &&\
    cp ../clang/tools/clang-format/git-clang-format /usr/bin &&\
    cd ../../ &&\
    rm -rf llvm-project/