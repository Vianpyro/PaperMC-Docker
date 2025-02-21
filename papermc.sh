#!/bin/bash

# Enter the papermc directory
cd /papermc

# Set default values if not provided
: ${MC_VERSION:='latest'}
: ${PAPER_BUILD:='latest'}
: ${MC_PORT:='25565'}

# Convert to lowercase to avoid 404 errors with wget
MC_VERSION="${MC_VERSION,,}"
PAPER_BUILD="${PAPER_BUILD,,}"

# Get the latest Minecraft version if "latest" is specified
if [[ $MC_VERSION == "latest" ]]; then
    LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[-1]')
    MC_VERSION="${LATEST_VERSION}"
    echo "Latest Minecraft version is ${MC_VERSION}"
fi

# Get the latest stable build for the specified Minecraft version
MINECRAFT_VERSION="${MC_VERSION}"

LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds | \
    jq -r '.builds | map(select(.channel == "default") | .build) | .[-1]')

if [[ "$LATEST_BUILD" != "null" ]]; then
    PAPER_BUILD="${LATEST_BUILD}"
    echo "Latest stable build for version ${MINECRAFT_VERSION} is ${PAPER_BUILD}"
else
    echo "No stable build for version ${MINECRAFT_VERSION} found :("
    exit 1
fi

# Define the jar file name and download URL
JAR_NAME="paper-${MINECRAFT_VERSION}-${PAPER_BUILD}.jar"
PAPERMC_URL="https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}"

# Download the server jar if it doesn't exist
if [[ ! -f $JAR_NAME ]]; then
    echo "Downloading Paper server jar for ${MINECRAFT_VERSION}-${PAPER_BUILD}..."
    curl -o server.jar $PAPERMC_URL
    echo "Download completed"
fi

# Write the EULA acceptance to the eula.txt file
echo "eula=${EULA:-false}" > eula.txt

# Add the RAM configuration to Java options if specified
if [[ -n $MC_RAM ]]; then
  JAVA_OPTS="-Xms${MC_RAM} -Xmx${MC_RAM} $JAVA_OPTS"
fi

# Start the Minecraft server with the provided configuration
echo "Starting Minecraft server on port ${MC_PORT}..."
exec java -server $JAVA_OPTS -jar server.jar nogui --port ${MC_PORT}
