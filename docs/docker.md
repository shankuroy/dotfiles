# Docker

## Install

Install with Colima rather than via Docker Desktop.

Add these to your Brewfile:

```ruby
brew "colima"                           # container runtime (https://colima.run/)
brew "docker"                           # container engine (https://docs.docker.com/engine/)
brew "docker-compose"                   # multi-container plugin for Docker (https://docs.docker.com/compose/)
```

Verify:

```sh
colima version
colima start
colima status
```

You should now have a `~/.docker` dir. Configure the CLI plugins reference. Add this to `~/.docker/config.json`:

```json
"cliPluginsExtraDirs": [
    "/opt/homebrew/lib/docker/cli-plugins"
]
```

Verify:

```sh
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

```sh
docker compose up
```

