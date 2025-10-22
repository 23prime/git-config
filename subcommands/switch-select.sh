#!/bin/bash

set -eu

# Check required commands
# shellcheck disable=SC2043
for cmd in fzf; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf "[ERROR] Required command '%s' not found. Please install it.\n" "$cmd" >&2
        exit 1
    fi
done

# Get current branch name
current_branch=$(git symbolic-ref --short HEAD)

# Fetch prune remote-tracking branches
git fetch --prune

# Select target branch interactively (include remote branches, exclude current branch)
target_branch=$(git branch --all --format='%(refname:short)' | grep -v "^$current_branch$" | fzf --prompt="Select branch to switch (current: $current_branch): ")

# Check if a branch was selected
if [ -z "$target_branch" ]; then
    exit 1
fi

# Switch to the selected branch exist at local
if git show-ref --verify --quiet "refs/heads/$target_branch"; then
    git switch "$target_branch"
else
    git switch -c "$target_branch" --track "$target_branch"
fi
