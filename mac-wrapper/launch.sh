#!/bin/bash
# Fist of Retribution: Project Zero - macOS launcher.
# The game files ship inside the app (Contents/Resources/game). On first launch, and whenever the app is updated,
# they are copied to ~/Library/Application Support/FistOfRetribution, where the game can write its settings and
# saves; the player's save/ folder is kept across updates. If the game can't start, a message box says why and
# the details are in last_run.log in that folder.
HERE="$(cd "$(dirname "$0")" && pwd)"
RES="$HERE/../Resources/game"
DATA="$HOME/Library/Application Support/FistOfRetribution"
LOG="$DATA/last_run.log"

say() {
	/usr/bin/osascript -e "display dialog \"$1\" with title \"Fist of Retribution\" buttons {\"OK\"} default button 1 with icon caution" >/dev/null 2>&1
}

mkdir -p "$DATA"
{
	echo "launch $(date)"
	echo "macOS $(sw_vers -productVersion 2>/dev/null)  cpu $(uname -m)  translated $(sysctl -n sysctl.proc_translated 2>/dev/null)"
	echo "app $HERE"
} > "$LOG"

if [ "$(uname -m)" != "arm64" ] && [ "$(sysctl -n hw.optional.arm64 2>/dev/null)" != "1" ]; then
	say "This build runs on Apple silicon Macs (M1 or newer). This Mac has an Intel processor - tell Claude and an Intel build will be made."
	exit 1
fi
major="$(sw_vers -productVersion 2>/dev/null | cut -d. -f1)"
if [ -n "$major" ] && [ "$major" -lt 13 ]; then
	say "This game needs macOS 13 (Ventura) or newer. This Mac has macOS $(sw_vers -productVersion)."
	exit 1
fi

STAMP="$(cat "$RES/.build" 2>/dev/null)"
if [ ! -f "$DATA/.build" ] || [ "$(cat "$DATA/.build")" != "$STAMP" ]; then
	for d in chars data external font sound stages; do
		rm -rf "$DATA/$d"
		cp -R "$RES/$d" "$DATA/$d" 2>>"$LOG" || { say "Couldn't copy the game files to $DATA. Details are in last_run.log there."; exit 1; }
	done
	mkdir -p "$DATA/save"
	echo "$STAMP" > "$DATA/.build"
fi
cd "$DATA" || exit 1

start=$(date +%s)
"$HERE/FistOfRetribution" "$@" >>"$LOG" 2>&1
code=$?
echo "exit $code after $(( $(date +%s) - start ))s" >> "$LOG"
if [ $code -ne 0 ]; then
	tailtxt="$(tail -n 6 "$LOG" | tr '"\\' "'/" | tr '\n' ' ' | cut -c1-600)"
	say "The game stopped (code $code). Send Claude the file last_run.log from ~/Library/Application Support/FistOfRetribution. Last lines: $tailtxt"
fi
exit $code
