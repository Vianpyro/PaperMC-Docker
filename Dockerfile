# Use Alpine as the base image for smaller size and performance
FROM alpine:latest

# Environment variables for Minecraft configuration
ENV MC_VERSION="latest" \
    PAPER_BUILD="latest" \
    EULA="false" \
    MC_RAM="2G" \
    JAVA_OPTS=""

# Install necessary packages
RUN apk update && apk add --no-cache \
    libstdc++ \
    openjdk21-jre \
    bash \
    wget \
    curl \
    jq

# Set the working directory inside the container
WORKDIR /server

# Copy the startup script into the container
COPY papermc.sh .

# Expose the port dynamically based on MC_PORT environment variable
EXPOSE 25565/tcp
EXPOSE 25565/udp

# Define the volume for Minecraft server data (to persist data)
VOLUME /server

# Healthcheck to ensure server is up and responding
HEALTHCHECK --interval=5m --timeout=3s --start-period=30s --retries=3 \
    CMD curl --silent --fail localhost:25565 || exit 1

# Start the Minecraft server using the bash script
CMD ["bash", "./papermc.sh"]
