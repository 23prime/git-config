#!/bin/bash

set -eu

# Check required commands
for cmd in fzf awk; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf "[ERROR] Required command '%s' not found. Please install it.\n" "$cmd" >&2
        exit 1
    fi
done

# Get current branch name
current_branch=$(git symbolic-ref --short HEAD)

# Select target branch interactively (exclude current branch)
target_branch=$(git branch --format='%(refname:short)' | grep -v "^$current_branch$" | fzf --prompt="Select branch to cherry-pick from: ")

# Check if a branch was selected
if [ -z "$target_branch" ]; then
    echo "No branch selected. Exiting." >&2
    exit 1
fi

# Select commit interactively from the specified branch and cherry-pick it
commit_hash=$(git log --oneline --color=always "$target_branch" | fzf --ansi --no-sort --prompt="Select commit to cherry-pick: " | awk '{print $1}')
if [ -n "$commit_hash" ]; then
    git cherry-pick "$commit_hash"
fi
