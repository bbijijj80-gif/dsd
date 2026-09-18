#!/usr/bin/env bash
# Лвёнок с советом в нижней строке текущего терминала.
#
# Работает через DECSTBM (tput csr): резервирует последнюю строку экрана
# под виджет и обновляет её по таймеру, не трогая обычный вывод команд.
#
# Ограничения: если изменить размер окна терминала, нужно перезапустить
# (stop && start) — скрипт не следит за SIGWINCH. Полноэкранные программы
# (vim, htop, less) используют альтернативный буфер экрана и не портят
# виджет — он снова появится после их выхода.
#
# Для tmux есть более надёжный вариант без этих ограничений: смотри README.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIP_SCRIPT="$DIR/tip.sh"
INTERVAL="${LVENOK_INTERVAL:-15}"

TTY_ID="$(tty 2>/dev/null | tr -c 'A-Za-z0-9' '_')"
PID_FILE="${TMPDIR:-/tmp}/lvenok-${TTY_ID:-notty}.pid"

usage() {
	echo "Использование: $0 {start|stop|status}"
	exit 1
}

restore_terminal() {
	local lines
	lines=$(tput lines)
	tput csr 0 $((lines - 1))
	tput cup $((lines - 1)) 0
	tput el
	rm -f "$PID_FILE"
}

run_widget() {
	trap restore_terminal EXIT INT TERM
	local lines cols row
	lines=$(tput lines)
	cols=$(tput cols)
	row=$((lines - 1))

	tput csr 0 $((lines - 2))

	while true; do
		local tip
		tip="$("$TIP_SCRIPT" 2>/dev/null)"
		tip="${tip:0:cols}"

		tput sc
		tput cup "$row" 0
		tput el
		printf '%s' "$tip"
		tput rc

		sleep "$INTERVAL"
	done
}

start() {
	if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
		echo "Уже запущен в этом терминале (PID $(cat "$PID_FILE"))."
		exit 0
	fi
	run_widget &
	echo $! >"$PID_FILE"
	echo "Лвёнок запущен (PID $!). Остановить: $0 stop"
}

stop() {
	if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
		kill "$(cat "$PID_FILE")"
		echo "Остановлен."
	else
		echo "Не запущен в этом терминале."
		rm -f "$PID_FILE"
	fi
}

status() {
	if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
		echo "Запущен (PID $(cat "$PID_FILE"))."
	else
		echo "Не запущен."
	fi
}

case "${1:-}" in
start) start ;;
stop) stop ;;
status) status ;;
*) usage ;;
esac
