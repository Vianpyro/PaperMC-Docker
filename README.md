# Minecraft PaperMC Server Docker Image

This repository contains a **Dockerfile** for creating a Minecraft Paper server, which can be easily configured and containerized using Docker.
The image supports **dynamic version selection**, **custom RAM allocation**, **EULA acceptance**, and **custom ports** for running multiple server instances.

## Features

-   **Use of Alpine Base**: A small and efficient base image (`alpine:latest`) with OpenJDK 21 for better security and performance.
-   **Dynamic Versioning**: Choose between the latest version or specify a particular Minecraft version.
-   **Custom RAM Allocation**: Dynamically allocate memory using the `MC_RAM` environment variable.
-   **EULA Acceptance**: Dynamically set the EULA acceptance (`EULA=true` or `EULA=false`).
-   **Multiple Instance Support**: Run multiple instances of the server on different ports by specifying the `MC_PORT` environment variable.
-   **Data Persistence**: Use Docker volumes or bind mounts to persist Minecraft world data, configurations, and backups.
-   **Health Check**: Automatically restarts the container if the server is unresponsive, ensuring the server remains online.

## Prerequisites

-   **Docker**: Install Docker on your system if you haven't already. Follow the installation instructions at https://docs.docker.com/get-docker/.

## Setup Instructions

### Build the Docker Image

1. Clone this repository to your local machine.
2. Navigate to the directory where the Dockerfile is located.
3. Build the Docker image using the following command:

    ```bash
    docker build -t minecraft-server .
    ```

    This will create the `minecraft-server` Docker image.

### Run the Docker Container

You can run multiple instances of the server on different ports by using the `-e MC_PORT` environment variable to specify the port for each instance.

#### Example: Run Minecraft Server on Default Port (25565)

```bash
docker run -d -p 25565:25565 --name minecraft-server-1 \
  --restart always \
  -v /path/to/minecraft/data-1:/papermc \
  -e EULA=true \
  -e MC_VERSION=latest \
  -e MC_RAM=2G \
  -e MC_PORT=25565 \
  minecraft-server
```

#### Example: Run Minecraft Server on Custom Port (25566)

```bash
docker run -d -p 25566:25565 --name minecraft-server-2 \
  --restart always \
  -v /path/to/minecraft/data-2:/papermc \
  -e EULA=true \
  -e MC_VERSION=1.18.1 \
  -e MC_RAM=4G \
  -e MC_PORT=25565 \
  minecraft-server
```

#### Example: Run Minecraft Server with Custom Version and RAM Allocation

```bash
docker run -d -p 25567:25565 --name minecraft-server-3 \
  --restart always \
  -v /path/to/minecraft/data-3:/papermc \
  -e EULA=true \
  -e MC_VERSION=1.17.1 \
  -e MC_RAM=4G \
  -e MC_PORT=25565 \
  minecraft-server
```

### Environment Variables

The following environment variables are available for configuring the Minecraft server:

-   **`MC_VERSION`**: Set the Minecraft version you want to run. Default: `latest`. Example: `1.18.1`.
-   **`PAPER_BUILD`**: Set the build number for Paper. Default: `latest`.
-   **`EULA`**: Set whether you accept the Minecraft EULA. Accepting is required to run the server. Default: `false`. Set it to `true` to accept the EULA.
-   **`MC_RAM`**: Set the amount of RAM to allocate for the Minecraft server. Example: `2G`, `4G`. Default: No RAM specified.
-   **`MC_PORT`**: Set the port for the Minecraft server to listen on. Default: `25565`. Example: `25566`.

### Data Persistence

To persist data across container restarts, you must mount a host directory as a volume. For example, to mount `/path/to/minecraft/data` from your host machine:

```bash
-v /path/to/minecraft/data:/papermc
```

This ensures that Minecraft's world data, server settings, and other configurations are saved outside the container. You can then back up the data or transfer it to a different server as needed.

### Health Check

The Docker container includes a health check to ensure the server is up and responsive. If the server becomes unresponsive, Docker will mark the container as unhealthy and attempt to restart it.

## Docker Compose Example

If you're using **Docker Compose** to manage your containers, here's an example `docker-compose.yml` file for running multiple Minecraft server instances:

```yaml
version: "3.8"

services:
    minecraft-server-1:
        image: minecraft-server
        container_name: minecraft-server-1
        ports:
            - "25565:25565"
        volumes:
            - /path/to/minecraft/data-1:/papermc
        environment:
            - EULA=true
            - MC_VERSION=latest
            - MC_RAM=2G
            - MC_PORT=25565
        restart: always

    minecraft-server-2:
        image: minecraft-server
        container_name: minecraft-server-2
        ports:
            - "25566:25565"
        volumes:
            - /path/to/minecraft/data-2:/papermc
        environment:
            - EULA=true
            - MC_VERSION=1.18.1
            - MC_RAM=4G
            - MC_PORT=25565
        restart: always

    minecraft-server-3:
        image: minecraft-server
        container_name: minecraft-server-3
        ports:
            - "25567:25565"
        volumes:
            - /path/to/minecraft/data-3:/papermc
        environment:
            - EULA=true
            - MC_VERSION=1.17.1
            - MC_RAM=4G
            - MC_PORT=25565
        restart: always
```

With **Docker Compose**, you can easily manage multiple instances of the Minecraft server by simply running:

```bash
docker-compose up -d
```

This will launch all three Minecraft servers on different ports.

---

## Additional Notes

-   **Backups**: The persistent data stored in `/path/to/minecraft/data` (or any directory you specify) can be backed up, moved, or restored. Simply copy the contents of this directory to another location for safekeeping.
-   **Resource Usage**: Be mindful of the system resources (RAM and CPU) when running multiple Minecraft server instances. You may need to adjust your `MC_RAM` settings based on your hardware specifications.
-   **Docker Restart Policy**: The `--restart always` flag ensures that the Minecraft server container will restart if it crashes or if Docker is restarted.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
