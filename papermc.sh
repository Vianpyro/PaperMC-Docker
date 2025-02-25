#!/bin/bash

set -e

# Enter the papermc directory
cd /server || exit 1

# Set default values if not provided
: "${MC_VERSION:='latest'}"
: "${PAPER_BUILD:='latest'}"

# Convert to lowercase to avoid 404 errors with wget
MC_VERSION="${MC_VERSION,,}"
PAPER_BUILD="${PAPER_BUILD,,}"

# Get the latest Minecraft version if "latest" is specified
if [[ $MC_VERSION == "latest" ]]; then
    MC_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[-1]')
    echo "Resolved latest Minecraft version: ${MC_VERSION}"
fi

# Get the latest stable build for the specified Minecraft version
LATEST_BUILD=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds" | \
    jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')

if [[ "$LATEST_BUILD" == "null" || -z "$LATEST_BUILD" ]]; then
    echo "No stable build found for version ${MC_VERSION}!"
    exit 1
fi

PAPER_BUILD="${LATEST_BUILD}"
echo "Using PaperMC build: ${PAPER_BUILD}"

# Define the jar file name and download URL
JAR_NAME="paper-${MC_VERSION}-${PAPER_BUILD}.jar"
PAPERMC_URL="https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}"

# Remove old JARs
rm -f paper-*.jar

# Download the latest server jar if not present
if [[ ! -f $JAR_NAME ]]; then
    echo "Downloading PaperMC server jar..."
    curl -o server.jar -fsSL "$PAPERMC_URL" || { echo "Download failed!"; exit 1; }
    echo "Download completed."
fi

# Write the EULA acceptance to the eula.txt file
echo "eula=${EULA:-false}" > eula.txt

# Build Java options array
JAVA_OPTS_ARRAY=()

# Include Aikar's optimized flags if enabled
if [[ "$USE_AIKAR_FLAGS" == "true" ]]; then
    AIKAR_FLAGS=(
        "-XX:+AlwaysPreTouch" "-XX:+DisableExplicitGC" "-XX:+ParallelRefProcEnabled"
        "-XX:+PerfDisableSharedMem" "-XX:+UnlockExperimentalVMOptions" "-XX:+UseG1GC"
        "-XX:G1HeapRegionSize=8M" "-XX:G1HeapWastePercent=5" "-XX:G1MaxNewSizePercent=40"
        "-XX:G1MixedGCCountTarget=4" "-XX:G1MixedGCLiveThresholdPercent=90" "-XX:G1NewSizePercent=30"
        "-XX:G1RSetUpdatingPauseTimePercent=5" "-XX:G1ReservePercent=20" "-XX:InitiatingHeapOccupancyPercent=15"
        "-XX:MaxGCPauseMillis=200" "-XX:MaxTenuringThreshold=1" "-XX:SurvivorRatio=32"
        "-Dusing.aikars.flags=https://mcflags.emc.gs" "-Daikars.new.flags=true"
    )
    JAVA_OPTS_ARRAY+=("${AIKAR_FLAGS[@]}")
fi

# Append user-defined Java options
if [[ -n $JAVA_OPTS ]]; then
    read -r -a USER_OPTS <<< "$JAVA_OPTS"
    JAVA_OPTS_ARRAY+=("${USER_OPTS[@]}")
fi

# Append memory settings
if [[ -n $MC_RAM ]]; then
    JAVA_OPTS_ARRAY+=("-Xms${MC_RAM}" "-Xmx${MC_RAM}")
fi

# Start the Minecraft server
echo "Starting Minecraft server with options: ${JAVA_OPTS_ARRAY[*]}"
exec java -server "${JAVA_OPTS_ARRAY[@]}" -jar server.jar nogui
