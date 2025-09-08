#!/bin/bash

set -eu

# Check required commands
for cmd in git fzf awk; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf "[ERROR] Required command '%s' not found. Please install it.\n" "$cmd" >&2
        exit 1
    fi
done

# Check if branch name is provided
if [ $# -eq 0 ]; then
    echo "Usage: git cherry-pick-select <branch_name>" >&2
    exit 1
fi

target_branch="$1"

# Check if the target branch exists
if ! git show-ref --verify --quiet "refs/heads/$target_branch"; then
    echo "Error: Branch '$target_branch' does not exist" >&2
    exit 1
fi

# Get current branch name
current_branch=$(git symbolic-ref --short HEAD)

# Prevent cherry-picking from the current branch
if [ "$target_branch" = "$current_branch" ]; then
    echo "Error: Cannot cherry-pick from the current branch ($current_branch)" >&2
    exit 1
fi

# Select commit interactively from the specified branch and cherry-pick it
commit_hash=$(git log --oneline --color=always "$target_branch" | fzf --ansi --no-sort | awk '{print $1}')
if [ -n "$commit_hash" ]; then
    git cherry-pick "$commit_hash"
fi
