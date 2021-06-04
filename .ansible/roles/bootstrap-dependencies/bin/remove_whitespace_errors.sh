#!/usr/bin/env bash

# Remove trailing whitespace
git grep -I --name-only -z -e '' \
    | xargs -0 sed -Ei 's/[ \t]+(\r?)$//'

# Remove trailing newline
#git grep -I --name-only -z -e '' \
    #| xargs -0 perl -0 -i -p -e 'chomp if eof'
    #| xargs -0 sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba'
