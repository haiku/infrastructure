#!/usr/bin/env sh
set -e

check_errors()
{
  # Function. Parameter 1 is the return code
  # Para. 2 is text to display on failure.
  if [ "${1}" -ne "0" ]; then
    echo "ERROR # ${1} : ${2}"
    # as a bonus, make our script exit with the right error code.
    exit ${1}
  fi
}

if [ "$1" = 'pootle' ]; then
    if [ ! -f $POOTLE_SETTINGS ]; then
        pootle init --config $POOTLE_SETTINGS
    fi

    exec supervisord
elif [ "$1" = 'synchronize' ]; then
    cd /var/pootle/repository && python /app/synchronize.py
fi
