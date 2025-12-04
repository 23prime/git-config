#!/bin/bash

set -eu

print_usage() {
    cat <<'EOF'
Usage: git sync-upstream [--branch=BRANCH] [--origin=ORIGIN] [--upstream=UPSTREAM] [--push]
EOF
}

# Parse arguments
## Defaults
BRANCH=main
ORIGIN=origin
UPSTREAM=upstream
PUSH=false

## Parse
while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
        print_usage
        exit 0
        ;;
    --branch=*)
        BRANCH="${1#*=}"
        shift
        ;;
    --branch)
        BRANCH="$2"
        shift 2
        ;;
    --origin=*)
        ORIGIN="${1#*=}"
        shift
        ;;
    --origin)
        ORIGIN="$2"
        shift 2
        ;;
    --upstream=*)
        UPSTREAM="${1#*=}"
        shift
        ;;
    --upstream)
        UPSTREAM="$2"
        shift 2
        ;;
    --push)
        PUSH=true
        shift
        ;;
    *)
        print_usage
        exit 1
        ;;
    esac
done

# Syncing
echo "[INFO] Syncing branch '$BRANCH' from '$UPSTREAM' into '$ORIGIN'..."

git pull "$ORIGIN" "$BRANCH"
git fetch "$UPSTREAM"
git merge "$UPSTREAM/$BRANCH"

if [ "$PUSH" = true ]; then
    echo "[INFO] Pushing merged changes to '$ORIGIN'..."
    git push "$ORIGIN" "$BRANCH"
fi
