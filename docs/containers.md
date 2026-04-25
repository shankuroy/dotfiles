# Containers

## Docker containers on macOS with [Colima](https://colima.run/)

Install with Colima rather than via Docker Desktop.

Add these to your Brewfile:

```ruby
brew "colima"                           # container runtime (https://colima.run/)
brew "docker"                           # container engine (https://docs.docker.com/engine/)
brew "docker-buildx"                    # BuildKit for Docker (https://github.com/docker/buildx)
brew "docker-compose"                   # multi-container plugin for Docker (https://docs.docker.com/compose/)
brew "lazydocker"                       # docker TUI (https://github.com/jesseduffield/lazydocker)
```

or manually install them:

```bash
brew install colima docker docker-buildx docker-compose lazydocker
```

Verify:

```bash
colima version
brew services start colima
colima status
```

To edit CPU/memory and other settings, edit `~/.colima/default/colima.yaml` and restart with:

```bash
brew services restart colima
```

You should now have a `~/.docker` dir. Configure the CLI plugins reference. Add this to `~/.docker/config.json`:

```json
"cliPluginsExtraDirs": [
    "/opt/homebrew/lib/docker/cli-plugins"
]
```

Verify:

```bash
docker --version
docker compose version
```

Test container:

```
docker run hello-world
```

Test compose:

Create a `docker-compose.yml` with this content:

```yml
services:
  hello-service:
    image: hello-world
```

Run it with:

```bash
docker compose up
```

## Apple containers on macOS with [container](https://github.com/apple/container)

```bash
brew install container
container system start
container run --rm hello-world
container image rm hello-world
```