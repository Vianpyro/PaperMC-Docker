#!/bin/bash

# Enter the papermc directory
cd /server || exit

# Set default values if not provided
: "${MC_VERSION:='latest'}"
: "${PAPER_BUILD:='latest'}"

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

LATEST_BUILD=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${MINECRAFT_VERSION}/builds" | \
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

# Remove old JARs
rm -f paper-*.jar

# Download the latest server jar
if [[ ! -f $JAR_NAME ]]; then
    echo "Downloading Paper server jar for ${MINECRAFT_VERSION}-${PAPER_BUILD}..."
    curl -o server.jar "$PAPERMC_URL"
    echo "Download completed"
fi

# Write the EULA acceptance to the eula.txt file
echo "eula=${EULA:-false}" > eula.txt

# Ensure JAVA_OPTS is initialized correctly
JAVA_OPTS="${JAVA_OPTS:-}"

# Append MC_RAM settings if specified
if [[ -n $MC_RAM ]]; then
  JAVA_OPTS="${JAVA_OPTS} -Xms${MC_RAM} -Xmx${MC_RAM}"
fi

# Start the Minecraft server with the provided configuration
echo "Starting Minecraft server with options: $JAVA_OPTS"
exec java -server $(echo "$JAVA_OPTS") -jar server.jar nogui
