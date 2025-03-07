# Minecraft PaperMC Server Docker Image

This repository contains a **Dockerfile** for creating a Minecraft Paper server, which can be easily configured and containerized using Docker.
The image supports **dynamic version selection**, **custom RAM allocation**, **EULA acceptance**, and **custom ports** for running multiple server instances.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Minimum Arguments to Start the Container](#minimum-arguments-to-start-the-container)
- [Setup Instructions](#setup-instructions)
  - [Build the Docker Image](#build-the-docker-image)
  - [Run the Docker Container](#run-the-docker-container)
- [Environment Variables](#environment-variables)
- [Timezone Configuration](#timezone-configuration)
- [Health Check](#health-check)
- [Docker Compose Example](#docker-compose-example)
- [Additional Notes](#additional-notes)
- [License](#license)

## Features

- **Use of Alpine Base**: A small and efficient base image (`alpine:latest`) with OpenJDK 21 for better security and performance.
- **Dynamic Versioning**: Choose between the latest version or specify a particular Minecraft version.
- **Custom RAM Allocation**: Dynamically allocate memory using the `MC_RAM` environment variable.
- **EULA Acceptance**: Dynamically set the EULA acceptance (`EULA=true` or `EULA=false`).
- **Data Persistence**: Use Docker volumes or bind mounts to persist Minecraft world data, configurations, and backups.
- **Health Check**: Automatically restarts the container if the server is unresponsive, ensuring the server remains online.

## Prerequisites

- **Docker**: Install Docker on your system if you haven't already. Follow the installation instructions at [Get Docker](https://docs.docker.com/get-docker/).

## Notes

- This image uses the `latest` tag for both Alpine and PaperMC versions.
  While best practice is to pin specific versions for predictability and security, this project is all about staying on the cutting edge.
  Security? It's taking a nice nap six feet under. LGTM 👍

## Minimum Arguments to Start the Container

To start a Minecraft PaperMC server with the absolute minimum required arguments:

```bash
docker run -d papermc-server
```

### Basic Run Command Breakdown

- `-d` → Runs the container in detached mode (in the background)
- `papermc-server` → The name of the Docker image

By default, the container will use `MC_VERSION=latest`, `MC_RAM=6G`, and other default values from the `Dockerfile`.
However, **players will not be able to join** since no ports are exposed.

To allow players to connect, expose the necessary ports:

```bash
docker run -d -p 25565:25565 -e EULA=true papermc-server
```

## Setup Instructions

### Build the Docker Image

1. Clone this repository to your local machine.
2. Navigate to the directory where the Dockerfile is located.
3. Build the Docker image using the following command:

   ```bash
   docker build -t papermc-server .
   ```

   This will create the `papermc-server` Docker image.

### Run the Docker Container

#### Example: Run Minecraft Server on Default Port (25565)

```bash
docker run -dit -p 25565:25565 --name papermc-server-1 papermc-server
```

#### Example: Run Minecraft Server on Custom Port (25566)

```bash
docker run -dit -p 4269:25565 --name papermc-server-2 papermc-server
```

#### Example: Run Minecraft Server with Custom Version and RAM Allocation

```bash
docker run -dit -p 25565:25565 --name papermc-server-3 \
  -e MC_VERSION=1.20.1 \
  -e MC_RAM=4G \
  papermc-server
```

### Why Use `-it`?

The `-it` flags (`-i` for interactive mode and `-t` for pseudo-TTY) allow you to interact with the Minecraft server console after starting the container.
This means you can run server commands directly by attaching to the running container using:

```bash
docker attach papermc-server-1
```

To detach from the console without stopping the server, use `Ctrl + P`, `Ctrl + Q`.

### Environment Variables

The following environment variables are available for configuring the Minecraft server:

- **`MC_VERSION`**: Set the Minecraft version you want to run. Default: `latest`. Example: `1.18.1`.
- **`PAPER_BUILD`**: Set the build number for Paper. Default: `latest`.
- **`EULA`**: Set whether you accept the Minecraft EULA. Accepting is required to run the server. Default: `false`. Set it to `true` to accept the EULA.
- **`MC_RAM`**: Set the amount of RAM to allocate for the Minecraft server. Example: `2048M`, `4G`. Default: `6G`.
- **`JAVA_OPTS`**: Additional Java options for customizing the JVM behavior. Example: `-Xms2G -Xmx4G -XX:+UseG1GC`.
- **`USE_AIKAR_FLAGS`**: Set to true to enable Aikar’s JVM flags for optimized performance. Default: `true`.

> [!NOTE]
> PaperMC recommends allocating at least **6-10GB of RAM**, regardless of the number of players.
> See [PaperMC's documentation](https://docs.papermc.io/paper/aikars-flags) for details.
>
> The `USE_AIKAR_FLAGS` environment variable add the Java options from the official PaperMC start script generator: [PaperMC Start Script Generator](https://docs.papermc.io/misc/tools/start-script-gen).

### Timezone Configuration

By default, the container will inherit the host's timezone settings.
If you need to define a specific timezone inside the container, uncomment the following line in the Dockerfile:

```dockerfile
# ENV TZ="Europe/Paris"
```

Or use bind mounts to synchronize with the host:

```bash
docker run -dit -p 25565:25565 --name papermc-server-1 \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  papermc-server
```

### Health Check

The Docker container includes a health check to ensure the server is up and responsive.
If the server becomes unresponsive, Docker will mark the container as unhealthy and attempt to restart it.

## Docker Compose Example

Using **Docker Compose**, you can manage multiple Minecraft server instances more easily.

```yaml
services:
  papermc-server-1:
    image: papermc-server
    container_name: papermc-server-1
    user: "1001:1001"
    volumes:
      - /path/to/minecraft/data-1:/server
    ports:
      - "25565:25565"
    restart: always
    stdin_open: true
    tty: true

  papermc-server-2:
    image: papermc-server
    container_name: papermc-server-2
    user: "1001:1001"
    volumes:
      - /path/to/minecraft/data-2:/server
    ports:
      - "25566:25565"
    environment:
      - MC_VERSION=1.18.2
      - PAPER_BUILD=333
      - EULA=true
      - MC_RAM=5120M
      - USE_AIKAR_FLAGS=true
    restart: unless-stopped
    stdin_open: true
    tty: true

  papermc-server-3:
    image: papermc-server
    container_name: papermc-server-3
    user: "1001:1001"
    volumes:
      - /path/to/minecraft/data-3:/server
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    ports:
      - "25567:25565"
    environment:
      - MC_VERSION=1.17.1
      - EULA=true
      - MC_RAM=4G
      - JAVA_OPTS=-XX:+UseG1GC -XX:+UnlockExperimentalVMOptions
    restart: always
    stdin_open: true
    tty: true
```

### Compose File Breakdown

- `version: '3.8'`: Defines the Docker Compose file format.
- Each service represents a Minecraft server instance.
- `container_name`: Assigns a unique name for each container.
- `image: papermc-server`: Specifies the image to use.
- `user`: Runs the container as a specific non-root user for security.
- `volumes`: Mounts a directory for persistent data.
  - `/path/to/minecraft/data:/server`: Persists Minecraft server files by mapping them to the host.
  - `/etc/localtime:/etc/localtime:ro` & `/etc/timezone:/etc/timezone:ro`: Ensures the container uses the host's timezone settings.
- `ports`: Maps the host machine's port to the container.
- `environment`: Sets environment variables, including `TZ` for timezone configuration.
- `stdin_open` & `tty`: Enables interactive mode for console interaction.
- `restart`: Ensures the container restarts automatically when needed.

Start all servers using:

```bash
docker-compose up -d
```

This will launch all Minecraft servers on different ports.

---

## Additional Notes

- **Backups**: The persistent data stored in `/server` can be backed up, moved, or restored. Simply copy the contents of this directory to another location for safekeeping.
- **Resource Usage**: Be mindful of the system resources (RAM and CPU) when running multiple Minecraft server instances. You may need to adjust your `MC_RAM` settings based on your hardware specifications.
- **Docker Restart Policy**: The `--restart unless-stopped` flag ensures that the Minecraft server container will restart if it crashes or if Docker is restarted.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
