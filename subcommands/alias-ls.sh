#!/bin/bash

set -eu

if ! git config --get-regexp '^alias\.'; then
    echo "No alias found."
fi
