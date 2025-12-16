FROM ghcr.io/haiku/general-worker:20251216 AS build

LABEL org.opencontainers.image.source="https://github.com/haiku/infrastructure"
LABEL org.opencontainers.image.url="https://github.com/haiku/infrastructure/tree/master/containers/ci/toolchain-worker"
LABEL org.opencontainers.image.vendor="Haiku, Inc."
LABEL org.opencontainers.image.description="Toolchain container for Haiku build automation."

ENV ARCHITECTURES "x86_gcc2 x86 x86_64 arm arm64 riscv64 ppc sparc"
ARG HAIKU_CHECKOUT
ARG BUILDTOOLS_CHECKOUT
ENV HAIKU_CHECKOUT ${HAIKU_CHECKOUT:-HEAD}
ENV BUILDTOOLS_CHECKOUT ${BUILDTOOLS_CHECKOUT:-HEAD}

# Initial Setup
RUN mkdir /tmp/src && \
	mkdir /toolchains && \
	cd /tmp/src && \
	git clone https://review.haiku-os.org/haiku && \
	git clone https://review.haiku-os.org/buildtools && \
	cd /tmp/src/haiku && \
	git checkout $HAIKU_CHECKOUT && \
	git describe --dirty --tags --long --match=hrev* > /toolchains/haiku-git-info && \
	cd /tmp/src/buildtools && \
	git checkout $BUILDTOOLS_CHECKOUT && \
	git describe --dirty --tags --long --match=btrev* > /toolchains/buildtools-git-info && \
	cd /tmp/src/buildtools/jam && \
	make && ./jam0 install

# Build each of our toolchains (get some coffee)
WORKDIR /toolchains
RUN THREADS=$(nproc); \
	if [ $THREADS -gt 8 ]; then THREADS=8; fi; \
	for i in ${ARCHITECTURES}; do \
	  echo "=== Building $i..." ; \
	  SCRIPT="/tmp/src/haiku/build/scripts/build_cross_tools"; \
	  MACHINE=$(/tmp/src/haiku/build/scripts/find_triplet $i); \
	  if [ "$i" != "x86_gcc2" ]; then SCRIPT="${SCRIPT}_gcc4"; fi; \
	  $SCRIPT $MACHINE /tmp/src/haiku /tmp/src/buildtools /toolchains/cross-tools-$i -j$THREADS ; \
	  find /toolchains/cross-tools-$i -type f -and -executable -and -regex ".*\/bin\/.*" -exec strip {} \; ; \
	done; \
	rm -rf /toolchains/build && rm -f /toolchains/Jamfile

# Build our final container, patch gcc2 stuff
FROM ghcr.io/haiku/general-worker:20251216
COPY --from=build /toolchains /toolchains
RUN echo "export ARCHITECTURES=\"${ARCHITECTURES}\"" >> ~/.profile && \
    echo "export PATH=$(for i in ${ARCHITECTURES}; do echo -n /toolchains/cross-tools-$i/bin:; done | sed 's/:$//g'):$PATH" >> ~/.profile && \
    GCC2PATH=$(strings /toolchains/cross-tools-x86_gcc2/bin/i586-pc-haiku-cpp | grep gcc-lib | grep crosstools | cut -d/ -f1,2,3,4,5) && \
    mkdir -p $GCC2PATH; ln -s /toolchains/cross-tools-x86_gcc2 $GCC2PATH/cross-tools-x86_gcc2; \
    echo "Corrected GCC2PATH for #15197; added virtual $GCC2PATH/cross-tools-x86_gcc2"; \
