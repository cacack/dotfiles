#!/usr/bin/env bash

# check for a temporary timezone change.
# shellcheck source=/dev/null
if [ -r ~/timezone.sh ]; then
	source ~/timezone.sh
fi
