# Codex In Docker

Run Codex inside Docker while limiting host exposure to the current workspace
and your local `~/.codex` directory.

## Files

- `Dockerfile`: minimal Codex CLI image.
- `compose.yml`: optional Compose launcher for the same image.
- `bin/codex`: wrapper that can replace your normal `codex` command.
- `config.toml.example`: optional host-side profile snippet.

## Why this layout

- Outer boundary: Docker only sees the mounts you allow.
- Inner boundary: Codex still runs in `workspace-write`.
- Persistent state: `~/.codex` is mounted into the container for auth and local config.

## Build

```bash
cd codex_docker
docker build -t local/codex-cli:latest .
```

## Use The Wrapper

Run it from any repository root:

```bash
/absolute/path/to/docker-compose-files/codex_docker/bin/codex
```

Make it your default `codex` command:

```bash
mkdir -p ~/bin
ln -sf /absolute/path/to/docker-compose-files/codex_docker/bin/codex ~/bin/codex
```

The wrapper:

- bind-mounts the current directory to `/workspace`;
- persists Codex state through host `~/.codex`;
- mounts host `~/.gitconfig` read-only when it exists;
- keeps host `~/.ssh` out by default.

## Optional SSH Access

Forward the running SSH agent:

```bash
CODEX_FORWARD_SSH_AGENT=1 codex
```

Or mount `~/.ssh` read-only:

```bash
CODEX_MOUNT_SSH_DIR=1 codex
```

Rebuild the image on demand:

```bash
CODEX_REBUILD=1 codex --version
```

## Compose Usage

```bash
cd codex_docker
export CODEX_WORKSPACE="$PWD/.."
export CODEX_HOME_DIR="$HOME/.codex"
export CODEX_UID="$(id -u)"
export CODEX_GID="$(id -g)"
docker compose run --rm codex
```

## Host Config

The wrapper starts Codex with:

```bash
--sandbox workspace-write --ask-for-approval on-request
```

If you want a matching profile for occasional direct Codex use, merge
`config.toml.example` into `~/.codex/config.toml` and select the `docker`
profile when needed.
