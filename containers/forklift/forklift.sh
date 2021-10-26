#!/bin/bash

# This is all pretty simple.  We *might* want to automate package_hardlinks
# in the future.. but it seems better today to do it manually

export INCOMING=/incoming
export OUTGOING=/haikuports-data/build-packages/master/packages/

# build-packages
while true; do
	for i in arm arm64 m68k ppc sparc riscv64 x86 x86_64; do
		if [ ! "$(ls -A ${INCOMING}/build-packages/${i})" ]; then
			continue;
		else
			echo "new build-packages inbound for $i..."
			ls -la ${INCOMING}/build-packages/${i}
			find ${INCOMING}/build-packages/${i} -name "*.hpkg" -mmin +15 -exec mv -v -f {} ${OUTGOING}/ \;
		fi
	done
	sleep 5m
done
