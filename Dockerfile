# Use Alpine as the base image for smaller size and performance
FROM alpine:latest

# Environment variables for configuration
ENV MC_VERSION="latest" \
    PAPER_BUILD="latest" \
    EULA="false" \
    MC_RAM="6G" \
    JAVA_OPTS="" \
    USE_AIKAR_FLAGS="true"

# Uncomment the following line to set a specific timezone
# ENV TZ="Europe/Paris"

# Copy the startup script to the container root
COPY papermc.sh /papermc.sh

# Create a non-root user and group
RUN addgroup -S minecraft && adduser -S minecraft -G minecraft && \
    mkdir -p /server && \
    chown -R minecraft:minecraft /server && \
    chmod +x /papermc.sh

# Install dependencies
RUN apk add --no-cache \
    libstdc++ \
    openjdk21-jre \
    bash \
    curl \
    jq \
    tzdata

# Set the working directory
WORKDIR /server

# Switch to the non-root user
USER minecraft

# Make the script the default startup command
ENTRYPOINT ["/papermc.sh"]

# Expose the TCP port for Minecraft server
EXPOSE 25565/tcp

# Define the volume for Minecraft server data (to persist data)
VOLUME /server

# Healthcheck to ensure server is up and responding
HEALTHCHECK --interval=5m --timeout=3s --start-period=90s --retries=3 \
    CMD nc -z 0.0.0.0 25565 || exit 1
