#!/bin/bash
# Usage: ./scripts/install_mod_locally.sh <PR_NUMBER>
# Downloads the latest CI artifact from a PR and installs it into the Factorio mods folder.
set -e

PR="$1"
if [ -z "$PR" ]; then
    echo "Usage: $0 <PR_NUMBER>" >&2
    exit 1
fi

command -v gh >/dev/null 2>&1 || { echo "gh CLI not found. Install from https://cli.github.com" >&2; exit 1; }

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
MODS_DIR="$HOME/Library/Application Support/factorio/mods"

echo "Repo:  $REPO"
echo "PR:    #$PR"

# Get head SHA
HEAD_SHA=$(gh api "repos/$REPO/pulls/$PR" --jq '.head.sha')
echo "SHA:   $HEAD_SHA"

# Find latest CI run for this commit
RUN_ID=$(gh api "repos/$REPO/actions/runs?head_sha=$HEAD_SHA" \
    --jq '[.workflow_runs[] | select(.name == "CI")] | sort_by(.created_at) | last | .id // empty')

if [ -z "$RUN_ID" ]; then
    echo "No CI run found for SHA $HEAD_SHA" >&2
    exit 1
fi
echo "Run:   $RUN_ID"

# Wait for completion
while true; do
    RUN_JSON=$(gh api "repos/$REPO/actions/runs/$RUN_ID" --jq '{status, conclusion}')
    STATUS=$(echo "$RUN_JSON" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    CONCLUSION=$(echo "$RUN_JSON" | grep -o '"conclusion":"[^"]*"' | cut -d'"' -f4)

    if [ "$STATUS" = "completed" ]; then
        if [ "$CONCLUSION" != "success" ]; then
            echo "CI failed (conclusion: $CONCLUSION). Check: https://github.com/$REPO/actions/runs/$RUN_ID" >&2
            exit 1
        fi
        echo "CI:    passed"
        break
    fi

    echo "CI:    $STATUS — waiting 15s..."
    sleep 15
done

# Find artifact
ARTIFACT_ID=$(gh api "repos/$REPO/actions/runs/$RUN_ID/artifacts" \
    --jq '.artifacts[] | select(.name == "factorio-mod-zip") | .id // empty')

if [ -z "$ARTIFACT_ID" ]; then
    echo "No factorio-mod-zip artifact in run $RUN_ID" >&2
    exit 1
fi

# Download to temp dir
TMPDIR=$(mktemp -d)
trap "rm -rf '$TMPDIR'" EXIT

echo "Downloading artifact $ARTIFACT_ID..."
gh api "repos/$REPO/actions/artifacts/$ARTIFACT_ID/zip" > "$TMPDIR/artifact.zip"

# Extract outer wrapper (GitHub always wraps artifacts in a zip)
unzip -q "$TMPDIR/artifact.zip" -d "$TMPDIR/inner"

# Find the mod zip inside
MOD_ZIP=$(find "$TMPDIR/inner" -maxdepth 1 -name "*.zip" | head -1)
if [ -z "$MOD_ZIP" ]; then
    echo "No .zip found inside artifact — unexpected structure" >&2
    exit 1
fi

MOD_FILENAME=$(basename "$MOD_ZIP")
# Strip version suffix to get the mod name (e.g. Todo-List_19.15.0.zip -> Todo-List)
MOD_NAME=$(echo "$MOD_FILENAME" | sed 's/_[0-9][0-9.]*\.zip$//')

echo "Mod:   $MOD_FILENAME"

# Remove previous versions of this mod
mkdir -p "$MODS_DIR"
OLD=$(find "$MODS_DIR" -maxdepth 1 -name "${MOD_NAME}_*.zip" 2>/dev/null)
if [ -n "$OLD" ]; then
    echo "Removing old: $(basename $OLD)"
    rm -f "$MODS_DIR/${MOD_NAME}_"*.zip
fi

# Install
cp "$MOD_ZIP" "$MODS_DIR/$MOD_FILENAME"
echo "Installed: $MODS_DIR/$MOD_FILENAME"
