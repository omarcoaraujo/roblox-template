#!/bin/sh
#
# Runs a command while every Roblox Studio window it opens is minimized without taking focus.
# Studio windows already open before the command starts are left alone, and each new window is
# minimized once, so restoring one by hand to watch it sticks.
#
# Minimizing another process's window needs the Win32 ShowWindow call, which only PowerShell
# reaches among the tools here. It is sent encoded so the script needs no quoting.

command -v powershell.exe >/dev/null 2>&1 || exec "$@"

watcher=$(cat <<'EOF'
$existing = @(Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue | ForEach-Object Id)
Add-Type -Name Window -Namespace Studio -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr handle, int command);'
$minimized = @{}
while ($true) {
	foreach ($process in Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue) {
		if ($existing -contains $process.Id) { continue }
		$handle = $process.MainWindowHandle
		if ($handle -eq [IntPtr]::Zero -or $minimized.ContainsKey($handle)) { continue }
		[Studio.Window]::ShowWindow($handle, 7) | Out-Null
		$minimized[$handle] = $true
	}
	Start-Sleep -Milliseconds 100
}
EOF
)

encoded=$(printf '%s' "$watcher" | iconv -f UTF-8 -t UTF-16LE | base64 -w0)

powershell.exe -NoProfile -EncodedCommand "$encoded" >/dev/null 2>&1 &
watcher_pid=$!

sleep 1

"$@"
status=$?

kill "$watcher_pid" 2>/dev/null
exit "$status"
