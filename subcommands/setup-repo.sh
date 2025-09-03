#!/bin/bash

set -eu

# Check that $1 (repo) is provided
if [ -z "${1:-}" ]; then
    echo "Usage: $0 <repo> [owner]" >&2
    exit 1
fi

repo=$1
owner=${2:-}

# Abort if directory with the same name as $repo already exists
if [ -d "$repo" ]; then
    echo "Error: Directory '$repo' already exists." >&2
    exit 1
fi

# Create local repository and initialize
mkdir -p "$repo"
cd "$repo"

git init
git initial-commit

# Create remote repository on GitHub
if [ -n "$owner" ]; then
    remote_repo="$owner/$repo"
else
    remote_repo="$repo"
fi

gh repo create "$remote_repo" --private --source=. --remote=origin --push
