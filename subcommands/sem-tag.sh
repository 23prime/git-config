#!/bin/bash

set -e

VERSION=$1

# Check if VERSION argument is provided
if [ -z "${VERSION:-}" ]; then
    echo "Error: VERSION argument is required" >&2
    exit 1
fi

# check version format vMAJOR.MINOR.PATCH
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: VERSION must be in format MAJOR.MINOR.PATCH, e.g. 1.2.3" >&2
    exit 1
fi

# Get latest tag
latest_tag=$(git tag --list 'v*' --sort=-v:refname | head -n 1)
echo "Latest tag: ${latest_tag:-None}"

if [ -n "$latest_tag" ]; then
    latest_version=${latest_tag#v}

    if [ "$(printf '%s\n%s\n' "$latest_version" "$VERSION" | sort -V | head -n 1)" != "$latest_version" ]; then
        echo "Error: Specified version $VERSION is not later than the latest tag $latest_tag" >&2
        exit 1
    fi
fi

echo "Creating and pushing tag v$VERSION"
read -r -p "Are you sure you want to create and push this tag? (y/n) " confirm

if [ "$confirm" != "y" ]; then
    echo "Tagging aborted"
    exit 1
fi

git tag -a -m "Release v$VERSION" "v$VERSION"
git push origin "v$VERSION"
