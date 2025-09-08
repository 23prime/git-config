#!/bin/bash

set -eu

# Check required commands
for cmd in fzf awk; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf "[ERROR] Required command '%s' not found. Please install it.\n" "$cmd" >&2
        exit 1
    fi
done

# Select commit interactively and show its details
commit_hash=$(git log --oneline --color=always | fzf --ansi --no-sort --prompt="Select commit to show: " | awk '{print $1}')
if [ -n "$commit_hash" ]; then
    git show --format=fuller "$commit_hash"
fi
