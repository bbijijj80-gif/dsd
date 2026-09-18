#!/usr/bin/env bash
# Печатает одну случайную подсказку из tips.txt. Используется и tmux
# status-line, и standalone-виджетом lvenok.sh.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIPS_FILE="$DIR/tips.txt"

mapfile -t TIPS <"$TIPS_FILE"
tip="${TIPS[RANDOM % ${#TIPS[@]}]}"

printf '🦁 Лвёнок: %s\n' "$tip"
