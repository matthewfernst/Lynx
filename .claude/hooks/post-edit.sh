#!/bin/bash

# Post-edit hook for Lynx project
# This hook runs after editing files to format Swift code

# Get the list of edited files from the environment variable
# CLAUDE_EDITED_FILES contains newline-separated list of edited file paths
if [ -n "$CLAUDE_EDITED_FILES" ]; then
    # Check if any Swift files were edited
    swift_files=$(echo "$CLAUDE_EDITED_FILES" | grep "\.swift$")

    if [ -n "$swift_files" ]; then
        echo "📝 Swift files were edited. Running swift-format..."

        # Format each edited Swift file
        echo "$swift_files" | while IFS= read -r file; do
            if [ -f "$file" ]; then
                echo "  Formatting: $file"
                xcrun swift-format -i "$file" 2>&1
            fi
        done

        echo "✅ Swift formatting complete!"
    fi
fi

exit 0
