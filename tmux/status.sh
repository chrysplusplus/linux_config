#!/usr/bin/env bash

if [[ -z "$CHS_MACHINE" ]]; then
  echo "Duck: 𐦖 #[fg=#505762]|#[fg=white] Pablo's cock: ꜥ===ᴈ"
elif [[ -e "$HOME/.safe_tmux_status" ]]; then
  battery="$(~/battery_percentage.sh)"
  echo "Battery: $battery"
else
  battery="$(~/battery_percentage.sh -c)"
  echo "Pablo's cock: $battery"
fi

