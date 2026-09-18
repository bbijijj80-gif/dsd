#!/usr/bin/env bash
# ⚠️ ТОЛЬКО для одноразовой VM! По-настоящему вызывает kernel panic.
#
# Подключается через `source ~/dsd/lvenok/rage.sh` в ~/.bashrc.
# Ничего не происходит, пока не выставлен LVENOK_RAGE_ENABLE=1.
# Установка и объяснение — lvenok/README.md, раздел "Режим ярости".

if [[ -n "${__LVENOK_RAGE_LOADED:-}" ]]; then
	return 0 2>/dev/null || exit 0
fi
__LVENOK_RAGE_LOADED=1

: "${LVENOK_RAGE_THRESHOLD:=5}"
: "${LVENOK_RAGE_ENABLE:=0}"

__lvenok_fail_streak=0

__lvenok_rage() {
	cat <<'EOF'
   /\_/\   RAWR!
  ( >X< )  ХВАТИТ ОШИБАТЬСЯ!!!
   > ~ <
EOF
	sleep 1
	sudo /usr/local/sbin/lvenok-panic
}

__lvenok_check_rage() {
	local status=$?
	[[ "$LVENOK_RAGE_ENABLE" == "1" ]] || return 0

	if ((status != 0)); then
		((__lvenok_fail_streak++))
		if ((__lvenok_fail_streak >= LVENOK_RAGE_THRESHOLD)); then
			__lvenok_fail_streak=0
			__lvenok_rage
		else
			local left=$((LVENOK_RAGE_THRESHOLD - __lvenok_fail_streak))
			echo "🦁💢 Лвёнок хмурится... ещё $left ошибок — и он взбесится."
		fi
	else
		__lvenok_fail_streak=0
	fi
}

PROMPT_COMMAND="__lvenok_check_rage${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
