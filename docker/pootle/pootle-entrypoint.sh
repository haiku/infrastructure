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
    # Save all the data to disk
    pootle sync_stores --force --overwrite
    check_errors $? "Error writing the current catalogs to disk"

    # Go to the repository directory and generate catalogs
    cd /var/pootle/repository
    git pull
    jam catkeys

    # Merge the templates
    python /app/import_templates_from_repository.py /var/pootle/repository/generated/objects/catalogs/ /var/pootle/catalogs/haiku/
    check_errors $? "Error importing the new translations from the repository and merging them to the translated files"

    # Load the translated files into Pootle
    pootle update_stores
    check_errors $? "Error importing the catalogs into pootle"

    # Output the translated catalogs to the repository
    python /app/finish_output_catalogs.py /var/pootle/catalogs/haiku /var/pootle/repository/data/catalogs/
    check_errors $? "Error copying the updated translations to the git tree"
    git add -A
    git commit -m "Update translations from Pootle"
    check_errors $? "Git Error: Error committing the changes to the repository"
    git pull --rebase
    check_errors $? "Git Error: Error pulling the latest revisions into the repository"
    git push
    check_errors $? "Git Error: Error pushing the translations to the Haiku repository"
fi

exec "$@"