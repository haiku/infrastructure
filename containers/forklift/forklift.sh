#!/bin/bash

# This is all pretty simple.  We *might* want to automate package_hardlinks
# in the future.. but it seems better today to do it manually

export INCOMING=/incoming
export OUTGOING=/haikuports-data/build-packages/master/packages

# build-packages
while true; do
	for i in arm arm64 m68k ppc sparc riscv64 x86 x86_64; do
		if [ ! -d "${INCOMING}/build-packages/${i})" ]; then
			echo "$(date) - build-packages/$i missing!"
			continue;
		fi
		if [ ! "$(ls -A ${INCOMING}/build-packages/${i})" ]; then
			continue;
		else
			echo "$(date) - new build-packages inbound for $i..."
			ls -la ${INCOMING}/build-packages/${i}
			# clobber architecture packages
			find ${INCOMING}/build-packages/${i} -name "*-${i}.hpkg" -mmin +30 -exec mv -v -f {} ${OUTGOING}/ \;
			# don't clobber source or any packages since it could break other architecture repos?
			find ${INCOMING}/build-packages/${i} -name "*-source.hpkg" -mmin +30 -exec mv -v -n {} ${OUTGOING}/ \;
			find ${INCOMING}/build-packages/${i} -name "*-any.hpkg" -mmin +30 -exec mv -v -n {} ${OUTGOING}/ \;
			# cleanup
			find ${INCOMING}/build-packages/${i} -name "*" -mmin +60 -exec rm -vf {} \;
		fi
	done
	sleep 5m
done
