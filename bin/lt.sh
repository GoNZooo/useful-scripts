#!/bin/env bash

# A script for displaying a file tree with `lsd` but automatically ignoring
# files in `.gitignore` files.

set -euo pipefail

if ! git rev-parse --is-inside-work-tree 2> /dev/null; then
    # not in a git directory, just run normal `lsd --tree` with all of our arguments
    lsd --tree $@
    # exit with the same exit code as `lsd`
    exit $?
fi

IGNORE_FILE=$(git rev-parse --show-toplevel)/.gitignore

IGNORED_FILES=""
if [ -f "$IGNORE_FILE" ]; then
    # take each ignored file (line) in the file and join them with `-I` before each entry
    IGNORED_FILES=$(cat "$IGNORE_FILE" | sed -e 's:/$::' -e 's:^/::' -e 's/^/-I "/' -e 's/$/"/' | tr '\n' ' ')
fi

COMMAND="lsd --tree $IGNORED_FILES $@"

eval $COMMAND
