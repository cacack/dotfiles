#!/usr/bin/env bash

tmux=$(which tmux)
winidx=$($tmux display-message -p '#I')

$tmux select-pane -t 0			# Ensure pane 0 is focused.
$tmux split-window -h -p 50		# Split pane 0 vertically 50%.
$tmux select-pane -t 1			# Focus pane 1.
$tmux split-window -v -p 25		# Split pane 1 horizontally 25%.
$tmux select-pane -t 0			# Return focus to pane 0.
