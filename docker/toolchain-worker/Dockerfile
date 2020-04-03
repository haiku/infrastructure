FROM haiku/general-worker:latest
MAINTAINER Haiku <contact@haiku-os.org>

ENV ARCHITECTURES "x86 x86_64 arm arm64 riscv64 ppc sparc"
ENV ARCHITECTURES_LEGACY "x86_gcc2"
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
	cd /tmp/src/buildtools && \
	git checkout $BUILDTOOLS_CHECKOUT && \
	cd /tmp/src/buildtools/jam && \
	make && ./jam0 install

# Build each of our toolchains (get some coffee)
WORKDIR /toolchains
RUN for i in ${ARCHITECTURES}; do \
	MACHINE=$(/tmp/src/haiku/build/scripts/find_triplet $i); \
	/tmp/src/haiku/build/scripts/build_cross_tools_gcc4 $MACHINE /tmp/src/haiku /tmp/src/buildtools /toolchains/cross-tools-$i -j$THREADS ; \
	find /toolchains/cross-tools-$i -type f -and -executable -and -regex ".*\/bin\/.*" -exec strip {} \; ; \
	done;

RUN for i in ${ARCHITECTURES_LEGACY}; do \
	/tmp/src/haiku/build/scripts/build_cross_tools /tmp/src/haiku /tmp/src/buildtools /toolchains/cross-tools-$i -j$THREADS ; \
	find /toolchains/cross-tools-$i -type f -and -executable -and -regex ".*\/bin\/.*" -exec strip {} \; ; \
	done;

# Add each toolchain to PATH and cleanup
RUN echo "export ARCHITECTURES=\"${ARCHITECTURES} ${ARCHITECTURES_LEGACY}\"" >> ~/.profile && \
	echo "export PATH=$(for i in ${ARCHITECTURES}; do echo -n /toolchains/cross-tools-$i/bin:; done | sed 's/:$//g'):$PATH" >> ~/.profile && \
	rm -rf /tmp/src && rm -rf /toolchains/build && rm -f /toolchains/Jamfile
