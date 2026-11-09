#!/bin/sh
#
# run-in-roblox 0.3.0 ships roblox_install 0.2.2, which finds Studio by reading the HKCU
# ContentFolder value and taking its parent as the install root. It never checks that the
# path still exists, so once Studio updates and the old version folder is deleted, the
# launch dies with a bare "os error 2" that names nothing.
#
# There is no newer run-in-roblox release and 0.2.2 has no ROBLOX_STUDIO_PATH override, so
# repointing the value is the only lever. Windows only; a no-op everywhere else.
#
# MSYS_NO_PATHCONV stops git bash from mangling the registry key into a POSIX path, which
# makes reg reject it as invalid syntax.

[ -n "$LOCALAPPDATA" ] || exit 0
command -v reg >/dev/null 2>&1 || exit 0

KEY='HKCU\Software\Roblox\RobloxStudio'

current=$(MSYS_NO_PATHCONV=1 reg query "$KEY" /v ContentFolder 2>/dev/null |
	sed -n 's/.*REG_SZ[[:space:]]*//p' | tr -d '\r')

if [ -n "$current" ] && [ -d "$(cygpath -u "$current" 2>/dev/null || echo "$current")" ]; then
	exit 0
fi

studio=$(ls -d "$LOCALAPPDATA"/Roblox/Versions/*/RobloxStudioBeta.exe 2>/dev/null | head -1)
[ -n "$studio" ] || exit 0

content="$(cygpath -w "$(dirname "$studio")")\\content\\"

if MSYS_NO_PATHCONV=1 reg add "$KEY" /v ContentFolder /t REG_SZ /d "$content" /f >/dev/null 2>&1; then
	echo "[studio] repaired stale ContentFolder -> $content"
else
	echo "[studio] could not repair ContentFolder; run-in-roblox may fail to launch Studio" >&2
fi
