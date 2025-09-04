#!/bin/bash

set -eu

awk '
/\[alias\]/ {
    print; in_alias=1; next
}
in_alias && /^[[:space:]]+[a-zA-Z0-9_-]+[[:space:]]*=/ {
    # Set indent to 2 spaces
    line = $0
    sub(/^[[:space:]]+/, "  ", line)
    # Ensure one space before and after '='
    sub(/[[:space:]]*=[[:space:]]*/, " = ", line)
    print line | "sort"; next
}
in_alias && $0 !~ /^[[:space:]]+[a-zA-Z0-9_-]+[[:space:]]*=/ {
    close("sort"); in_alias=0
}
{ print }
' alias.conf >alias.conf.tmp

mv alias.conf.tmp alias.conf
