#!/usr/bin/env bash

git grep -I --name-only -z -e '' \
    | xargs -0 sed -Ei 's/[ \t]+(\r?)$//'
#    | xargs -0 sed -i -e 's/[ \t]\+\(\r\?\)$/\1/;$a\'
