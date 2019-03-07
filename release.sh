#!/bin/sh

set -eu

faketorio package -c .travis/.faketorio -v

# If RELEASE
# get version from info.json
# git tag
# upload artifact