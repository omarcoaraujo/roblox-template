@echo off

blink "./src/remotes/init.blink"
asphalt sync

./scripts/wally-install.bat
./scripts/sourcemap.bat