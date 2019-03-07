#!/bin/sh

set -eu

if [ ! -f "$1" ]; then
    echo "File $1 not found!"
    exit 1
fi

./"$1"