# Roblox Template

<a href="https://github.com/omarcoaraujo/roblox-template/actions/workflows/check.yml"><img src="https://github.com/omarcoaraujo/roblox-template/actions/workflows/check.yml/badge.svg" alt="Check"/></a>

A starting point for Roblox projects: Rojo for syncing, pesde for packages, Blink for networking, ProfileStore for player data, Jest for unit tests and Scrim for multiplayer playtests, all wired together and run through `mise`.

Clone it, rename it and start building. Nothing in it needs to be deleted first.

## What is in it

- Sync to Studio with Rojo (`dev.project.json`)
- Packages with pesde and the public Wally registry (`pesde.toml`, installed into `roblox_packages` and `roblox_server_packages`)
- Networking with Blink (`src/remotes`, generates `src/shared/network`)
- Player data with ProfileStore (`src/server/profile`)
- Live tuning with Backstage (`data/shared/backstage.json` holds its port)
- A loading screen with three dots and a camera intro that plays when it ends (`src/loading`, `src/client/camera`)
- UI helpers: `px` scaling, Vide hooks, a button and a window component (`src/ui`, `src/shared/hooks`)
- Unit tests with Jest (`tests`, run by `mise run test`)
- Multiplayer playtests with Scrim (`playtests`, run by `mise run playtest`)
- Formatting and types with StyLua and luau-lsp (`mise run format`, `mise run analyze`)
- Continuous integration with GitHub Actions (`.github/workflows/check.yml`)

## Getting started

1. Install [Rokit](https://github.com/rojo-rbx/rokit) and [mise](https://mise.jdx.dev).
2. Install the tools pinned in `rokit.toml`:

```sh
rokit install
```

3. Copy `.env.example` to `.env` and fill what you use (see Environment).
4. Start the dev loop. It installs packages, generates the network code and serves the project to Studio:

```sh
mise run dev
```

5. In Studio, connect the Rojo plugin. Enable Allow HTTP Requests in the game settings so Backstage can talk to its tool.

## Tasks

| Command | What it does |
|---|---|
| `mise run dev` | Install, generate Blink, serve with Rojo and Backstage |
| `mise run build` | Install packages, build the sourcemap, generate Blink |
| `mise run blink` | Regenerate the network layer after editing `.blink` files |
| `mise run format` | Format with StyLua |
| `mise run analyze` | Type check with luau-lsp |
| `mise run test` | Build a test place and run the Jest suite headless |
| `mise run test -- --cloud` | Run the same suite through Open Cloud |
| `mise run playtest` | Run the Scrim specs in a real multiplayer Studio session |

`mise run test` and `mise run playtest` succeed while there are no specs yet.

## Layout

```
src/
  .client.luau       client entry point
  .server.luau       server entry point
  client/            client modules (camera intro)
  server/            server modules (profile, client_ready)
  shared/            shared code (hooks, utils, stores, generated network)
  remotes/           Blink definitions
  ui/                Vide components and px
  loading/           loading screen, runs before anything else replicates
  stories/           UI Labs storybook and its helper
data/
  shared/            shared data, one module per topic, exposed by init.luau
  server/            server-only data
tests/               Jest specs, named *.spec.luau, plus test helpers
playtests/           Scrim entry scripts and specs
scripts/             helpers for the test task
```

Both entry points load their modules from an `entries` list. The server loads them in order, the client loads them in parallel. Add a module to the list to boot it.

## Player data

`src/server/profile` opens one ProfileStore session per player. `template.luau` holds the defaults, `migrations.luau` the version steps. Other server modules read and write `profile.expect(player).Data`. The client reads its data with `net.player.get_data`, through `src/shared/stores/utils/get_player_data.luau`.

## Networking

Define every remote in `src/remotes` and never create a RemoteEvent by hand. After editing a `.blink` file:

```sh
mise run blink
```

The generated files in `src/shared/network` are ignored by git.

## Tests

Jest specs live in `tests` and end in `.spec.luau`. They run in a throwaway place built from `test.project.json`, so no Studio window and no Rojo sync are involved. Require `jest_globals` by instance, mock the Blink `net` module with `tests/helpers/net`, and keep the section order: services, packages, helpers, variables, setup, subject, tests. Tests and playtests are strict like the rest of the project.

Playtests live in `playtests/specs`, one folder per scenario with a `server.luau` and, when the scenario asks the client something, a `client.luau` that you register in `playtests/scrim/start_client.client.luau`. They need Studio and a place of your own.

On Windows, `mise run test` also runs two small scripts in `scripts`: one repoints the Studio install path that `run-in-roblox` reads when a Studio update removes the old folder, the other minimizes the Studio window the run opens.

## Environment

| Variable | Used by |
|---|---|
| `ROBLOX_API_KEY` | playtests (scope `legacy-asset:manage`) and cloud tests |
| `ROBLOX_PLAYTEST_PLACE_ID` | the place the playtests merge into |
| `ROBLOX_TEST_UNIVERSE_ID` | cloud tests and the CI test job |
| `ROBLOX_TEST_PLACE_ID` | cloud tests and the CI test job |

The CI test job is skipped while `ROBLOX_TEST_UNIVERSE_ID` is unset.

## Code style

- Luau with the `const` dialect, strict mode through `.luaurc`
- `snake_case` for files, folders and variables, `SCREAMING_SNAKE_CASE` for constants
- Sections in order, each under a `--// Section` header: Services, Packages, Modules, Utils, Components, Constants, Types, Variables, Functions, Component, End
- No comments. Names and structure carry the code, a section header is the only annotation
- String requires with the `@game` alias, `./` and `../` for siblings and parents, `@self/` for children of an `init.luau`

More detail for working with an AI assistant is in `CLAUDE.md`.

## Customize after cloning

- Rename the project in `dev.project.json`, `test.project.json` and `playtest.project.json`
- Rename the package in `pesde.toml`
- Change the holder in `LICENSE`
- Change the Backstage port in `data/shared/backstage.json` if another project already uses it
- Change the data store name in `src/server/profile/session.luau` if you need one other than `players`
- Fill `.env`

## License

MIT
