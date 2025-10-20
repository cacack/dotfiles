#!/usr/bin/env zsh

# Development layout with Claude, Neovim, and terminal
# Creates a 3-pane tmux layout: left pane for claude, top-right for nvim, bottom-right for terminal
dev() {
  # Check if we're inside a tmux session
  if [ -z "$TMUX" ]; then
    echo "Error: Not inside a tmux session"
    return 1
  fi

  # Split window vertically (left and right) - left pane gets 20% width
  tmux split-window -h -p 80

  # Split the right pane horizontally (top-right and bottom-right) - bottom pane gets 20% height
  tmux split-window -v -p 20

  # Send commands to each pane
  tmux send-keys -t 1 'claude' Enter  # Left pane: Claude
  tmux send-keys -t 2 'nvim' Enter    # Top-right pane: Neovim
  # Bottom-right pane remains as terminal (pane 2)

  # Set focus to the Claude pane
  tmux select-pane -t 1
}

# Close all tmux panes except the current one and return to single terminal
undev() {
  # Check if we're inside a tmux session
  if [ -z "$TMUX" ]; then
    echo "Error: Not inside a tmux session"
    return 1
  fi

  # Kill all panes except the current one
  tmux kill-pane -a
}
