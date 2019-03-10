#!/bin/bash

set -eu

# Ensure that the GITHUB_TOKEN secret is included
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

# Get version from mod
VERSION=$(jq --raw-output '.version' info.json)

# get latest tag
TAG=$(git tag | tail -n 1)

if [[ "$VERSION" = "$TAG" ]]; then
    echo "No new version. Aborting build."
    exit 78
fi

# We are on a new version
# Tag it
git tag "$VERSION"
git push --tags

# Build mod
faketorio package -c .travis/.faketorio -v

# Prepare the headers
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

# Build the Upload URL from the various pieces

RESPONSE=$(curl -sSL -XGET -H "$AUTH_HEADER" "https://api.github.com/repos/JonasJurczok/${GITHUB_REPOSITORY}/releases/tags/${TAG}")
RELEASE_TAG=$(jq --raw-output '.tag_name' "$RESPONSE")

if [[ "$TAG" != "$RELEASE_TAG" ]]; then
    echo "Previously created release does not exist. Cannot upload artifact!"
    exit -1
fi

RELEASE_ID=$(jq --raw-output '.id', "$RESPONSE")

# For each matching file
for file in $(ls target/Todo*.zip); do

    echo "Processing file ${file}"

    FILENAME=$(basename ${file})
    UPLOAD_URL="https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${FILENAME}"
    echo "$UPLOAD_URL"

    # Upload the file
    curl \
        -sSL \
        -XPOST \
        -H "${AUTH_HEADER}" \
        --upload-file "${file}" \
        --header "Content-Type:application/octet-stream" \
        "${UPLOAD_URL}"
done