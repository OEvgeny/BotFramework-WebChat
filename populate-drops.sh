#!/bin/bash

# Create drops directory if it doesn't exist
mkdir -p drops
rm drops/*

# Define package mappings
declare -A packages=(
    ["core"]="botframework-webchat-core"
    ["api"]="botframework-webchat-api"
    ["bundle"]="botframework-webchat"
    ["component"]="botframework-webchat-component"
    ["fluent-theme"]="botframework-webchat-fluent-theme"
    ["directlinespeech"]="botframework-directlinespeech-sdk"
)

# Navigate to the packages directory
cd ../BotFramework-WebChat/packages

# Process each package
for folder in "${!packages[@]}"; do
    if [ -d "$folder" ]; then
        echo "Processing ${packages[$folder]}..."
        
        # Navigate into the package directory
        cd "$folder"
        
        # Pack the package (this will create a .tgz file)
        npm pack
        
        # Move the package to the drops folder with the correct name
        mv *.tgz "../../../WebChat-release-testing/drops/${packages[$folder]}-0.0.0-0.tgz"
        
        # Navigate back to packages directory
        cd ..
        
        echo "✓ Finished ${packages[$folder]}"
    else
        echo "⚠ Warning: Directory $folder not found"
    fi
done

echo "All packages have been processed and moved to the drops folder."