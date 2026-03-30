@echo off
wally install

if exist "Packages" (
    ren "Packages" "packages"
)

if exist "ServerPackages" (
    ren "ServerPackages" "serverPackages"
)

rojo sourcemap dev.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json ./packages/
wally-package-types --sourcemap sourcemap.json ./serverPackages/