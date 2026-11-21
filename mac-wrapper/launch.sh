#!/bin/bash
# Fist of Retribution: Project Zero - macOS launcher.
# The game files ship inside the app (Contents/Resources/game). On first launch, and whenever the app is updated,
# they are copied to ~/Library/Application Support/FistOfRetribution, where the game can write its settings and
# saves; the player's save/ folder is kept across updates.
HERE="$(cd "$(dirname "$0")" && pwd)"
RES="$HERE/../Resources/game"
DATA="$HOME/Library/Application Support/FistOfRetribution"
STAMP="$(cat "$RES/.build" 2>/dev/null)"
if [ ! -f "$DATA/.build" ] || [ "$(cat "$DATA/.build")" != "$STAMP" ]; then
	mkdir -p "$DATA"
	for d in chars data external font sound stages; do
		rm -rf "$DATA/$d"
		cp -R "$RES/$d" "$DATA/$d"
	done
	mkdir -p "$DATA/save"
	echo "$STAMP" > "$DATA/.build"
fi
cd "$DATA" || exit 1
exec "$HERE/FistOfRetribution" "$@"
