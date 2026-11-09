# Roblox Template — CLAUDE.md

A starting point for Roblox projects. Clone it, rename it and build on it. Everything here is base: a toolchain, a boot sequence, a profile layer, a loading screen and the test setup. Game code goes in `src/` and `data/`.

### Non-negotiable rules

- **The server decides.** Anything that changes a player's data or the world is validated and applied on the server. The client asks, the server answers. Never trust an amount, a roll or a result reported by a client.
- **Profile writes go through the profile module.** No feature module touches ProfileStore or the session lock directly. Read and write `profile.expect(player).Data`, and fire the change to the client through a remote.
- **Never create a RemoteEvent by hand.** Every remote is declared in `src/remotes/**/*.blink` and used through the generated `net` module.
- **Never edit the generated network files** in `src/shared/network`. Edit the `.blink` files and run `mise run blink`.
- **A new way into or out of a flow must prepare and clear the same per-player state as the old one.** Before adding a join, leave, switch or spectate path, list what the existing path sets up and clears for each player, and match it.

---

## Project conventions

- `TODO.md` is ignored by git and is the only memory that survives a session. A task that shows up goes in it at once, as a flat short `- [ ]` line
- Search the web first when an engine API, an instance or a place-level flag behaves oddly: Roblox changes defaults often and the DevForum usually has the answer
- Before saying a feature is missing, open the implementation. A search that finds nothing proves nothing

---

## Toolchain

Pinned in `rokit.toml`.

| Tool | Purpose |
|---|---|
| `rojo` | Syncs the project to Roblox Studio |
| `pesde` | Package manager, with the public Wally registry as a second source |
| `blink` | Generates the networking layer from `.blink` files |
| `stylua` | Luau formatter |
| `luau-lsp` | Type checker |
| `asphalt` | Asset sync (images, sounds) |
| `backstage` | Live tuning tool that runs next to Studio |
| `scrim` | Playtest runner (CLI here, library through pesde) |
| `run-in-roblox` | Runs the Jest suite headless in Studio |
| `lute`, `lune` | Luau runtimes used by the test scripts and pesde |
| `mise` | Task runner that wraps all of the above |

### Common commands

```sh
mise run dev        # install packages, generate blink, serve with rojo and backstage
mise run build      # install packages, build the sourcemap, generate blink
mise run blink      # regenerate the network layer after editing .blink files
mise run format     # format with stylua
mise run analyze    # type-check with luau-lsp, run before finishing a change
mise run test       # build a test place and run the Jest suite headless
mise run playtest   # run the Scrim specs in a real multiplayer Studio session
```

`.env` (copy it from `.env.example`) is loaded by mise. `ROBLOX_API_KEY` and `ROBLOX_PLAYTEST_PLACE_ID` feed the playtests, `ROBLOX_TEST_UNIVERSE_ID` and `ROBLOX_TEST_PLACE_ID` feed the cloud tests.

---

## Testing

Specs live in `tests/`, named `*.spec.luau`, and run with `mise run test`. The task builds a throwaway place from `test.project.json` with `rojo build` and drives it through `run-in-roblox`, so no Studio window and no rojo sync are involved: it always tests the files as they are on disk. The runner exits 0 on pass and 1 on failure. With no spec in the folder it also exits 0 (`passWithNoTests`).

`run-in-roblox` needs a Studio install and reads where Studio lives from the Windows registry. Two scripts make it work on a Windows machine, and `mise run test` calls both:

- `scripts/repair_studio_path.sh` repoints the registry value when a Studio update deleted the old version folder, which otherwise kills the launch with a bare "os error 2"
- `scripts/minimized.sh` minimizes every Studio window the run opens, without taking focus

Both do nothing outside Windows. Do not remove them.

Tests and playtests are strict like the rest of the project: they inherit the root .luaurc, with no override.

**Workflow:** run `mise run analyze` while working, as the tight loop. When a task or system is finished, write the unit tests for it and run `mise run test` before calling it done. Type-checking and tests answer different questions: analyze proves it compiles, tests prove it behaves.

### Writing a spec

Section order is a hard constraint, not style. Luau has no hoisting, so `jest.mock` and any instance fixture must run **before** the module under test is required:

```
--// Services
--// Packages       jest_globals
--// Helpers        tests/helpers/*
--// Variables      describe, expect, it, jest
--// Functions      fixtures and factories
--// Setup          build the fixture, install jest.mock
--// Subject        the module being tested
--// Tests
```

- **Require `jest_globals` by instance** (`ReplicatedStorage.packages.jest_globals`), never by a string path: the Jest runtime intercepts the require by matching the instance. The same goes for the subject and anything passed to `jest.mock`
- **Always `jest.mock` the blink `net` module** with `tests/helpers/net`. Each spec file gets its own module registry, so a second spec re-running the real `net` makes blink abort with a remote scope conflict. Pass a table to the stub and it records each handler under its dotted path (`handlers["player.ready"]`)
- **`tests/helpers/player` builds a fake `Player`** for server modules that key tables by player
- **The test place has no authored geometry.** `rojo build` only materialises what the project file maps, so anything authored in the place must be built in the spec's Setup section first
- Prefer testing rules that were extracted into functions taking their state as an argument. Thin wrappers over third-party packages are not worth testing

### What to test

Server logic carries the suite: it is where the rules live and where regressions hurt. Client code is reactive (charm atoms into vide components), so test only store reducers, derived values and formatting helpers. Do not write tests that mount components. `px` stays in the UI because it drags in `workspace.CurrentCamera`.

Cover the rule as written, not a catalogue of imagined edge cases. When a real bug shows up, fix it and add the test that pins it. Blink types every field and validates on write, so malformed payloads never reach a handler; what is worth testing is a well-formed value that is still wrong.

There is no code coverage: Jest's coverage relies on instrumentation that has no Luau counterpart.

`mise run test -- --cloud` runs the same suite through Open Cloud against a place of its own, which is what CI uses. It needs `ROBLOX_API_KEY`, `ROBLOX_TEST_UNIVERSE_ID` and `ROBLOX_TEST_PLACE_ID`. The CI job skips itself while the universe id is unset.

### Playtests

Playtests run with Scrim, in a real multiplayer Studio session: the only place a second client, streaming or an authored world exists. `mise run playtest` builds `playtest.project.json` (the dev tree plus the Scrim entry scripts) and merges it into the last cloud save of the place in `ROBLOX_PLAYTEST_PLACE_ID`. Nothing is saved back. With no spec in `playtests/specs` the task says so and exits 0.

```sh
mise run playtest                       # every spec
mise run playtest -- --filter name      # specs whose name contains the text
mise run playtest -- --show --verbose   # leave Studio visible, print the raw log
```

A spec is a folder in `playtests/specs/` with a `server.luau` returning `{ players, run }` (the name defaults to the folder name) and, when the server needs to ask the client something, a `client.luau` returning named queries. A spec fails by erroring. Use `ctx.eventually` instead of sleeping and `ctx.defer` for cleanup. Register each `client.luau` in `playtests/scrim/start_client.client.luau`, as `folder_name = require(...)` inside `scrim.start`. The entry scripts live only in `playtest.project.json`, because `scrim.run` is not a no-op in a normal session. Run playtests on demand, never in CI. Game rules stay in Jest.

Two things no test reaches, so verify them by playing: anything that depends on real instance streaming, and anything a player has to *see*, such as animation timing, easing or whether an effect reads the way it should.

---

## Project Structure

```
src/
  .client.luau          # client entry point (StarterPlayerScripts)
  .server.luau          # server entry point (ServerScriptService)
  client/               # client-only modules (ReplicatedStorage.client_modules)
    camera/intro.luau   # pulls the camera back during loading and settles it when loading ends
  server/               # server-only modules (ServerStorage.server_modules)
    profile/            # ProfileStore session, template and migrations
    client_ready.luau   # tracks which clients finished booting
  shared/               # shared modules (ReplicatedStorage.shared)
    network/            # generated by blink, DO NOT edit manually
    hooks/              # vide hooks
    utils/              # pure helpers
    stores/             # charm atoms (state)
      navigation.luau   # which screen is open, plus a queue of screens
      utils/get_player_data.luau
      __mocks__/        # data returned inside UI Labs, where there is no server
  remotes/              # blink source files
    init.blink          # root: output paths and the namespaces it imports
    definitions/        # events and functions per namespace
    types/              # shared blink types per namespace
  ui/                   # vide components (ReplicatedStorage.ui)
    app.luau            # root component, mounted from .client.luau
    utils/px.luau       # resolution-independent sizing
    components/         # base components: button (press and hover scale) and window (opens when its name is the current screen)
  loading/              # ReplicatedFirst loading screen, depends on nothing else (data.luau and store.luau are its own)
  stories/              # UI Labs stories (dev only)
    interface.storybook.luau   # storybook that lists this folder
    loading.story.luau   # the loading screen, mounted through convert_to_frame
    utils/convert_to_frame.luau  # renders a ScreenGui inside the UI Labs panel
data/
  shared/               # shared data (ReplicatedStorage.data): backstage.json holds the Backstage port, camera.luau tunes the camera intro
  server/               # server-only data (ServerStorage.data)
tests/                  # Jest specs (ReplicatedStorage.tests)
  helpers/              # test doubles: the blink net stub and a fake player
  jest.config.luau
playtests/              # Scrim, only in playtest.project.json
  scrim/                # entry scripts calling scrim.run and scrim.start
  specs/                # one folder per scenario: server.luau and client.luau
scripts/                # run by the test task, not synced into the game
```

Packages install into `roblox_packages` (shared and client, mapped to `ReplicatedStorage.packages` and `ReplicatedFirst.packages`) and `roblox_server_packages` (mapped to `ServerStorage.server_packages`). Both are ignored by git.

---

## Key Packages

| Package | What it is | Where used |
|---|---|---|
| `vide` | Reactive UI framework | `src/ui/` |
| `charm` | Atom-based state | `src/shared/stores/` |
| `ripple` | Spring and tween animation | UI animation |
| `rng` | Weighted and seeded random helpers | Drop tables, rolls |
| `profile_store` | DataStore wrapper with session locking | `src/server/profile/` |
| `topbarplus` | Custom Roblox top bar | UI |
| `quickzone` | Touch zone detection | Zones |
| `ui_labs` | UI component playground | Dev only |
| `backstage` | Live tuning window for values | `data/shared/backstage.json` holds its port |
| `scrim` | Playtest library | `playtests/` |
| `jest`, `jest_globals` | Test framework | `tests/` |

---

## Networking (Blink)

All RemoteEvents and RemoteFunctions are defined in `src/remotes/**/*.blink`. After editing any `.blink` file:

```sh
mise run blink
```

This overwrites `src/shared/network/client.luau`, `server.luau` and `types.luau`.

```luau
-- server
const net = require "@game/ReplicatedStorage/shared/network/server"
net.player.ready.on(function(player) end)

-- client
const net = require "@game/ReplicatedStorage/shared/network/client"
net.player.ready.invoke()
```

Blink supports `Reliable` and `Unreliable` event types. Use `Unreliable` for high-frequency state that can be dropped.

---

## Architecture Notes

- **Entry points**: `.client.luau` and `.server.luau` load their modules from an `entries` list. Register a new module there. The server loads sequentially, so order matters (`profile` goes first); the client loads in parallel
- **Boot handshake**: when the client finishes loading its modules it calls `net.player.ready` and sets the `client_loaded` attribute. The server tracks it in `client_ready` (`is_ready`, `await_ready`)
- **Loading**: `src/loading` runs from ReplicatedFirst before anything else replicates, so it requires nothing from ReplicatedStorage. It shows a white screen with three grey dots that hop in place. As `game:IsLoaded()` and `client_loaded` open, the progress rises and each dot, at its share of the progress, turns blue and starts to jump. At 100% the dots shrink away, the `loading_finished` attribute is set and the white screen fades out. Its numbers live in `src/loading/data.luau` as a Backstage config, tuned live from the `loading` story in UI Labs; in a running game that config is switched off and returns a frozen copy, so it never waits for the game to load
- **Profile**: `src/server/profile` loads one ProfileStore session per player and ends it when the player leaves. `template.luau` holds the defaults and `migrations.luau` the version steps: add a step to `MIGRATIONS`, and the template follows `CURRENT_VERSION`. The client asks for its data through `net.player.get_data`; `src/shared/stores/utils/get_player_data.luau` is what stores use to read it, and inside UI Labs it returns the mock in `stores/__mocks__/player_data.luau`. A new field goes in the `data` blink struct, in the template and in the mock
- **Backstage**: `data/shared/backstage.json` holds the port. The game reads it as a module and `mise run dev` loads the same file into its environment to start the tool, so the number lives in one place. Enable Allow HTTP Requests in the game settings so Studio can talk to it
- **Camera intro**: `src/client/camera/intro.luau` pulls the camera back with a blur when the game opens and settles it behind the player when the `loading_finished` attribute is set, which happens as the loading fade starts. Its numbers live in `data/shared/camera.luau` as a Backstage config

---

## Code Style

- Luau with the `const` dialect, `--!strict` through `.luaurc`. Formatter: StyLua, run it before finishing (`mise run format`). Config in `stylua.toml`
- **Do not write comments.** Names and structure carry the code, and a section header is the only annotation a file gets
- Sections in this order, each under a `--// Section` header: Services, Packages, Modules, Utils, Components, Constants, Types, Variables, Functions, Component, End
- `const` for everything that is not reassigned. `snake_case` for files, folders, variables and network names. `SCREAMING_SNAKE_CASE` for constants
- String requires with the `@game/...` alias, resolved through the rojo sourcemap. `./` and `../` for siblings and parents, `@self/` for the children of an `init.luau`
- **Type variables with a trailing cast**, not a colon annotation, and only type what the solver cannot infer. Parameters keep the colon. Prefer generics to `any`
- Guard clauses and early returns over `else`. A nil guard stays glued to the line after it
- Split related fields into small groups with a blank line between groups, in types, table literals and setup blocks
- OOP, when needed: metatables with a private `_Foo` type for internal fields

---

## UI

- UI sizes go through `px`, never raw offsets. Whenever you work on a screen, sweep its instances for `UIPadding`, layout padding, `UICorner`, `UIStroke` thickness and any `UDim` with an offset and no scale, and drive them through `px` so they scale with the resolution. Keep the authored numbers as the input, for example `px.udim(padding.PaddingLeft.Scale, padding.PaddingLeft.Offset)`
- Call `px.use_px()` once inside the root of each screen that uses `px`
- Every clickable `GuiButton` needs `Active` on: a button with `Active = false` never fires `Activated`
- A component that goes inside a group must not put its layout on the frame the group touches
- Stories live in `src/stories/`, listed by `interface.storybook.luau`. A screen authored as a `ScreenGui` needs `stories/utils/convert_to_frame` to render inside the UI Labs panel. For anything timed, drive the story from an `elapsed` source with play and pause, so a frame can be held still and inspected
