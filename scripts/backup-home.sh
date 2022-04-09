#!/usr/bin/env bash

rsync -rav \
  --delete \
  --exclude '.cache' \
  --exclude '.mozilla' \
  --exclude '.pyenv' \
  --exclude '.var' \
  --exclude 'cloud' \
  --exclude 'shared' \
  /home/cac21/ \
  /run/media/cac21/passport/backups/clonch/home/
