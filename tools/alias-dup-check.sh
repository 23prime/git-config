#!/bin/bash

set -eu

in_alias=0
declare -A alias_map
dup=0

while IFS= read -r line; do
    if [[ $line =~ ^\[alias\] ]]; then
        in_alias=1
        continue
    fi

    if [[ $in_alias -eq 1 && $line =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*=(.*) ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"

        if [[ -n "${alias_map[$key]:-}" ]]; then
            echo "Duplicate: $key =${value}"
            dup=1
        fi

        alias_map["$key"]=1
    elif [[ $in_alias -eq 1 && ! $line =~ ^[[:space:]]*([a-zA-Z0-9_-]+)[[:space:]]*= ]]; then
        in_alias=0
    fi
done <alias.conf

if [[ $dup -eq 0 ]]; then
    echo "No duplicates found"
else
    echo "[ERROR] Duplicates found" >&2
    exit 1
fi
