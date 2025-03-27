# Docker Wait for Dependencies

[![License](https://img.shields.io/github/license/matteovivona/docker-wait-for-dependencies)](https://github.com/matteovivona/docker-wait-for-dependencies/blob/main/LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/ducktors/docker-wait-for-dependencies?logo=docker)](https://hub.docker.com/r/ducktors/docker-wait-for-dependencies)
[![amd64](https://img.shields.io/badge/arch-linux%2Famd64-brightgreen)](https://hub.docker.com/r/ducktors/docker-wait-for-dependencies/tags)
[![arm64](https://img.shields.io/badge/arch-linux%2Farm64-brightgreen)](https://hub.docker.com/r/ducktors/docker-wait-for-dependencies/tags)

A lightweight Docker container that ensures service dependencies are available before proceeding. This tool is perfect for orchestrating service startup order in Docker Compose environments.

## Features

- 🔍 TCP port availability checking
- ⚡ Lightweight Alpine-based image
- 🔒 Runs as non-root user for security
- 🏗️ Multi-architecture support (amd64, arm64)
- ⏱️ Configurable timeout and check intervals
- 🚀 Zero dependencies beyond netcat

## Quick Start

1. Pull the image:
```bash
docker pull ducktors/docker-wait-for-dependencies
```

2. Use in your docker-compose.yml:
```yaml
version: '3.8'
services:
  mongo:
    image: mongo:6
    ports:
      - 27017:27017
    networks:
      - app-network

  redis:
    image: redis:6
    ports:
      - 6379:6379
    networks:
      - app-network

  wait-for-deps:
    image: ducktors/docker-wait-for-dependencies
    depends_on:
      - mongo
      - redis
    command: mongo:27017 redis:6379
    networks:
      - app-network

  app:
    image: your-app
    depends_on:
      wait-for-deps:
        condition: service_completed_successfully
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SLEEP_LENGTH` | 2 | Time in seconds between dependency checks |
| `TIMEOUT_LENGTH` | 300 | Maximum time in seconds to wait for dependencies |

### Example with Custom Configuration

```yaml
wait-for-deps:
  image: ducktors/docker-wait-for-dependencies
  environment:
    - SLEEP_LENGTH=1
    - TIMEOUT_LENGTH=60
  command: mongo:27017 redis:6379
```

## Usage Examples

### Basic Usage
```bash
docker run --rm ducktors/docker-wait-for-dependencies localhost:5432
```

### Multiple Dependencies
```bash
docker run --rm ducktors/docker-wait-for-dependencies \
  postgres:5432 \
  redis:6379 \
  elasticsearch:9200
```

### With Custom Timeout
```bash
docker run --rm \
  -e TIMEOUT_LENGTH=120 \
  ducktors/docker-wait-for-dependencies \
  mysql:3306
```

## How It Works

1. The container checks each specified host:port combination
2. It waits until all services are available or timeout is reached
3. Returns exit code 0 if all services are available
4. Returns exit code 1 if timeout is reached or invalid input

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
