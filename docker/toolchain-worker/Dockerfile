FROM haiku/general-worker:latest
MAINTAINER Haiku <contact@haiku-os.org>

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
	cd /tmp/src/buildtools && \
	git checkout $BUILDTOOLS_CHECKOUT && \
	cd /tmp/src/buildtools/jam && \
	make && ./jam0 install

# Build each of our toolchains (get some coffee)
WORKDIR /toolchains
RUN for i in ${ARCHITECTURES}; do /tmp/src/haiku/configure --build-cross-tools $i /tmp/src/buildtools -j$(cat /proc/cpuinfo | egrep '^processor' | wc -l); done && \
	find /toolchains -type f -and -executable -and -regex ".*\/bin\/.*" -exec strip {} \;
 
# Add each toolchain to PATH and cleanup
RUN echo "export ARCHITECTURES=\"${ARCHITECTURES}\"" >> ~/.bashrc && \
	echo "export PATH=$(for i in ${ARCHITECTURES}; do echo -n /toolchains/cross-tools-$i/bin:; done | sed 's/:$//g'):$PATH" >> ~/.bashrc && \
	rm -rf /tmp/src && rm -rf /toolchains/build && rm -f /toolchains/Jamfile
