#!/bin/bash

set -eu

git log --oneline -n 1 | awk '{print $1}'
