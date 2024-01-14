#!/bin/bash
if [[ -z "$ADMIN_TOKEN" ]]; then
    export ADMIN_TOKEN="$(cat /opt/gitea/admin-token)"
fi

if [[ ! -z "$1" ]]; then
    REPO_URL="$1"
fi

if [[ -z "$2" ]]; then
    echo "Repo name is not set"
    exit 1
fi
REPO_NAME="$2"

if [[ -z "$REPO_URL" ]]; then
    echo "Repo URL is not set"
    exit 1
fi

curl -v -H "Content-Type: application/json" \
    -H "Authorization: token $ADMIN_TOKEN" \
    -d "{\"clone_addr\":\"$REPO_URL\",\"repo_name\":\"$REPO_NAME\"}" \
    http://localhost:3000/api/v1/repos/migrate