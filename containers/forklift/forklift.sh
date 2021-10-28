#!/bin/bash

# This is all pretty simple.  We *might* want to automate package_hardlinks
# in the future.. but it seems better today to do it manually

export INCOMING=/incoming
export OUTGOING=/haikuports-data/build-packages/master/packages

# build-packages
while true; do
	for i in arm arm64 m68k ppc sparc riscv64 x86 x86_64; do
		ARCH_PATH="${INCOMING}/build-packages/${i}"
		if [ ! -d "${ARCH_PATH}" ]; then
			echo "$(date) - ${ARCH_PATH} missing!"
			continue;
		fi
		if [ ! "$(ls -A ${ARCH_PATH})" ]; then
			continue;
		else
			echo "$(date) - new build-packages inbound for $i..."
			ls -la ${ARCH_PATH}
			# clobber architecture packages
			echo "$(date) - moving $i packages to build-packages repo..."
			find ${ARCH_PATH} -name "*-${i}.hpkg" -mmin +30 -exec mv -v -f {} ${OUTGOING}/ \;
			# don't clobber source or any packages since it could break other architecture repos?
			echo "$(date) - moving $i source/any packages to build-packages repo..."
			find ${ARCH_PATH} -name "*-source.hpkg" -mmin +30 -exec mv -v -n {} ${OUTGOING}/ \;
			find ${ARCH_PATH} -name "*-any.hpkg" -mmin +30 -exec mv -v -n {} ${OUTGOING}/ \;
			# cleanup
			echo "$(date) - cleaning up anything we don't need / want..."
			find ${ARCH_PATH} -name "*" -mmin +60 -exec rm -vf {} \;
		fi
	done
	sleep 5m
done
