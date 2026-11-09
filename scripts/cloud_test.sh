#!/bin/sh
# Builds the CI place, publishes it as a saved version and runs the suite against that version.
#
# The upload runs through curl here rather than inside cloud_test.luau: invoking curl from lute's
# process.run sends an empty body, and lute's own HTTP client is rejected by the place API. This
# shell form is the one that works.

set -e

# CI passes these in the environment; locally they come from .env, under the same names.
read_env() {
	[ -f .env ] || return 0
	grep "^$1=" .env | cut -d= -f2- | tr -d '\r"'"'"
}

resolve() {
	eval "value=\$$1"
	[ -n "$value" ] || value=$(read_env "$1")

	if [ -z "$value" ]; then
		echo "$1 is missing: set it in the environment or in .env" >&2
		exit 1
	fi

	eval "$1=\$value"
	export "$1"
}

resolve ROBLOX_API_KEY
resolve ROBLOX_TEST_UNIVERSE_ID
resolve ROBLOX_TEST_PLACE_ID

PLACE=test-place.rbxlx
rojo build test.project.json --output "$PLACE"

RESPONSE=$(curl --silent --show-error --request POST \
	--header "x-api-key: $ROBLOX_API_KEY" \
	--header "Content-Type: application/xml" \
	--data-binary "@$PLACE" \
	"https://apis.roblox.com/universes/v1/$ROBLOX_TEST_UNIVERSE_ID/places/$ROBLOX_TEST_PLACE_ID/versions?versionType=Saved")

VERSION=$(printf '%s' "$RESPONSE" | sed -n 's/.*"versionNumber":[[:space:]]*\([0-9]*\).*/\1/p')

if [ -z "$VERSION" ]; then
	echo "upload failed: $RESPONSE" >&2
	exit 1
fi

echo "uploaded place version $VERSION"
lute run scripts/cloud_test.luau "$VERSION" scripts/run_tests.luau
