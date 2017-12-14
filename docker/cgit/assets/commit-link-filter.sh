#!/bin/sh
# This script can be used to generate links in commit messages.
#
# To use this script, refer to this file with either the commit-filter or the
# repo.commit-filter options in cgitrc.

# This expression generates links to commits referenced by their SHA1.
regex=$regex'
s|(\s+)([0-9a-fA-F]{7,40})(\s+)|\1<a href="./?id=\2">\2</a>\3|g'

# This expression generates links to commits referenced by their revision tag.
regex=$regex'
s|(hrev[0-9]+)|<a href="./?id=\1">\1</a>|g'

# This expression generates links to Trac issues.
regex=$regex'
s|#([0-9]+)|<a href="http://dev.haiku-os.org/ticket/\1">#\1</a>|g'

sed -re "$regex"
