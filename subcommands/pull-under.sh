#!/bin/bash

set -eu

print_usage() {
    cat <<'EOF'
Usage: git pull-under [options] [ROOT]

Run `git pull` for all Git repositories directly under ROOT (depth = 1).
Uses the local repo subcommand `repo-ls` to discover repositories.

Options:
  -n, --dry-run    Print actions without executing.
  -h, --help       Show this help and exit.

Examples:
  git pull-under            # pull repos directly under current dir
  git pull-under -n ~/code  # dry-run under specified ROOT
EOF
}

DRY_RUN=0
ROOT=""

# Parse arguments (options may appear before or after ROOT)
while [ $# -gt 0 ]; do
    case "$1" in
    -n | --dry-run)
        DRY_RUN=1
        ;;
    -h | --help)
        print_usage
        exit 0
        ;;
    --)
        shift
        if [ $# -gt 0 ]; then
            if [ -n "$ROOT" ]; then
                printf "Error: Multiple ROOT paths specified: %s %s\n" "$ROOT" "$1" >&2
                exit 2
            fi
            ROOT="$1"
            shift
        fi
        if [ $# -gt 0 ]; then
            printf "Error: Unexpected extra argument: %s\n" "$1" >&2
            exit 2
        fi
        break
        ;;
    -*)
        printf "Unknown option: %s\n" "$1" >&2
        exit 2
        ;;
    *)
        if [ -n "$ROOT" ]; then
            printf "Error: Multiple ROOT paths specified: %s %s\n" "$ROOT" "$1" >&2
            exit 2
        fi
        ROOT="$1"
        ;;
    esac
    shift
done

ROOT=${ROOT:-.}

if [ ! -d "$ROOT" ]; then
    printf "Error: ROOT directory not found: %s\n" "$ROOT" >&2
    exit 1
fi

# Ensure `git repo-ls` is available
if ! git repo-ls -h >/dev/null 2>&1; then
    echo "[ERROR] 'git repo-ls' not found. Create subcommand links (e.g., 'task sub:create')." >&2
    exit 1
fi

# Collect repositories at depth=1 (absolute paths)
mapfile -t REPOS < <(git repo-ls -a -d 1 "$ROOT")

if [ ${#REPOS[@]} -eq 0 ]; then
    echo "No repositories found at depth=1 under: $ROOT"
    exit 0
fi

errors=0

for repo in "${REPOS[@]}"; do
    echo "==> $repo"

    # Determine if repo is bare; 'git pull' is invalid for bare repositories
    if git -C "$repo" rev-parse --is-bare-repository >/dev/null 2>&1; then
        is_bare=$(git -C "$repo" rev-parse --is-bare-repository)
    else
        is_bare=false
    fi

    if [ "$is_bare" = "true" ]; then
        cmd=(git -C "$repo" fetch --all --prune)
    else
        cmd=(git -C "$repo" pull)
    fi

    echo "$ ${cmd[*]}"

    if [ "$DRY_RUN" -eq 1 ]; then
        continue
    fi

    if ! "${cmd[@]}"; then
        echo "[ERROR] command failed for: $repo" >&2
        errors=$((errors + 1))
    fi
    echo
done

if [ "$DRY_RUN" -eq 1 ]; then
    echo "Dry-run only. No commands executed."
fi

if [ "$errors" -gt 0 ]; then
    echo "Completed with $errors error(s)." >&2
    exit 1
fi

echo "All done."
