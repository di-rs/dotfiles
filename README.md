# dotfiles

Personal configs for Homebrew packages, helix, ghostty, zsh/zim, herdr, pi,
Claude Code, and the agent-skills registry, managed with
[GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a stow package whose internal path mirrors `$HOME`.

## Layout

```
brew/.Brewfile                  (macOS only)
macos/.zprofile                 (macOS only)
helix/.config/helix/config.toml
ghostty/.config/ghostty/config.ghostty
zsh/.zshrc .zshenv .zimrc
herdr/.config/herdr/config.toml
pi/.pi/agent/settings.json
agent-skills/.agents/.skill-lock.json
claude/.claude/settings.json .claude/plugins/known_marketplaces.json
```

`brew` and `macos` are only stowed on macOS (`install.sh` checks `uname -s`).
On Linux, `.Brewfile` and the Mac-specific `.zprofile` PATH entries are
skipped entirely — everything else is cross-platform.

`.Brewfile` is generated with `brew bundle dump` and read via
`brew bundle --global` (which looks for `~/.Brewfile`). Regenerate it after
installing/removing packages:

```sh
brew bundle dump --file=~/personal/.dotfiles/brew/.Brewfile --force
dotsync "update Brewfile"
```

## Install

```sh
git clone <this repo> ~/personal/.dotfiles
cd ~/personal/.dotfiles
./install.sh
```

`install.sh` detects the OS, installs GNU Stow if missing (via Homebrew on
macOS; on Linux it expects your distro's package manager, e.g.
`apt install stow`), symlinks the relevant packages into `$HOME`, and on
macOS runs `brew bundle --global` to install everything listed in
`.Brewfile`. If a target file already exists (e.g. a fresh machine's default
`.zshrc`), stow will refuse to overwrite it — move it aside first.

After stowing, restore agent skills from the lockfile:

```sh
npx skills experimental_install -g
```

fnm has no config file — its behavior comes from env vars set in `.zshrc`
(already tracked) plus whichever version is symlinked as its `default` alias,
which lives in fnm's data dir, not something stow can track. `install.sh`
pins that explicitly: `fnm install --lts && fnm default lts-latest`, then
reinstalls the global `pi` npm package under it. Don't hardcode a Node bin
path into `.zshrc` for tools like `pi` — that silently pins to whatever
version was default at the time and stops tracking `fnm default` when it
changes (this repo hit exactly that bug once).

## What's deliberately excluded

This repo only ever contains configuration, never state or secrets:

- **pi**: `auth.json` (live OAuth tokens) and `sessions/` (transcripts) are
  excluded. Only `settings.json` is tracked.
- **Claude Code**: `~/.claude.json` (account/session state), `projects/`,
  `sessions/`, `history.jsonl`, and caches are excluded. Only `settings.json`
  and the plugin marketplace list are tracked.
- **herdr**: `session.json` (live workspace/pane state), logs, and sockets are
  excluded. Only `config.toml` is tracked.
- **zim**: the `.zim/` framework directory itself isn't tracked — `.zshrc`
  already re-installs it from `.zimrc` via `zimfw` on first run.
- **agent-skills**: only `.skill-lock.json` is tracked, not the fetched skill
  content — `npx skills experimental_install -g` re-fetches it from source.
- Herdr's auto-generated integration shims (`~/.pi/agent/extensions/herdr-agent-state.ts`,
  `~/.claude/hooks/herdr-agent-state.sh`) aren't tracked; herdr regenerates
  and overwrites them on install/update anyway.
