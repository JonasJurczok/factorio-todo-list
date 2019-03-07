#!/bin/sh

set -eu

# Ensure that the GITHUB_TOKEN secret is included
if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

# Only upload to non-draft releases
IS_DRAFT=$(jq --raw-output '.release.draft' $GITHUB_EVENT_PATH)
if [ "$IS_DRAFT" = true ]; then
  echo "This is a draft, so nothing to do!"
  exit 0
fi

# update info.json
VERSION=$(jq --raw-output '.release.tag_name' $GITHUB_EVENT_PATH)

jq '.version = $new' --arg new "$VERSION" info.json > info.tmp
mv info.tmp info.json
rm -f info.tmp

faketorio package -c .travis/.faketorio -v

# Prepare the headers
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

# Build the Upload URL from the various pieces
RELEASE_ID=$(jq --raw-output '.release.id' $GITHUB_EVENT_PATH)

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