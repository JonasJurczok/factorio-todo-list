#!/bin/bash

set -euo pipefail

if [ ! -f "$1" ]; then
    echo "File $1 not found!"
    exit 1
fi
chmod 755 "$1"
./"$1"