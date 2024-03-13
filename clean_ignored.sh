#!/bin/bash

# Navigate to the Git repository root
cd "$(git rev-parse --show-toplevel)"

# List all ignored files
ignored_files=$(git ls-files --ignored --exclude-standard --others)

# Check if there are any ignored files
if [ -z "$ignored_files" ]; then
    echo "No ignored files to remove."
    exit 0
fi

# Loop through each ignored file and remove it
while IFS= read -r file; do
    echo "Removing $file..."
    rm -f "$file"
done <<< "$ignored_files"

echo "Ignored files have been removed."
