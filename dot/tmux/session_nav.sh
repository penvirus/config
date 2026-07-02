#!/usr/bin/env bash

# Get the current session name
current=$(tmux display-message -p '#S')

# Read all sessions into an array
sessions=()
while IFS= read -r line; do
    sessions+=("$line")
done <<< "$(tmux list-sessions -F '#S')"

len=${#sessions[@]}

# If there is only 1 session, just show it normally
if [[ $len -le 1 ]]; then
  echo "#[fg=green,bright][ Session: $current ]"
  exit 0
fi

# Find the index of the current session
for i in "${!sessions[@]}"; do
  if [[ "${sessions[$i]}" == "$current" ]]; then
    idx=$i
    break
  fi
done

# Calculate previous and next indices (with wrap-around)
prev_idx=$(( (idx - 1 + len) % len ))
next_idx=$(( (idx + 1) % len ))

prev_sess="${sessions[$prev_idx]}"
next_sess="${sessions[$next_idx]}"

# Output the formatted string with colors
echo "#[fg=cyan,nobright]$prev_sess #[fg=white]<- #[fg=green,bright][ $current ] #[fg=white]-> #[fg=cyan,nobright]$next_sess"
