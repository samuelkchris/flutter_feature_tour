#!/bin/bash

# Check if images directory exists
if [ ! -d "images" ]; then
    echo "Error: images directory not found"
    exit 1
fi

# Create temporary file for the demo section
cat << 'EOF' > temp_demo.md
## Demo

Below are demonstrations of the Feature Tour in action:

<!-- BEGIN DEMO -->
EOF

# Loop through all images in the images directory
for img in images/*; do
    if [ -f "$img" ]; then
        # Get filename without path
        filename=$(basename "$img")
        # Get name without extension for caption
        name=$(basename "$filename" | sed 's/\.[^.]*$//')
        # Convert demo1 to "Demo 1" for caption
        caption=$(echo "$name" | sed 's/\([a-z]\)\([0-9]\)/\1 \2/g' | sed 's/^./\U&/g')

        # Add image and caption to temp file
        echo "![${caption}](${img})" >> temp_demo.md
        echo "*${caption}*" >> temp_demo.md
        echo "" >> temp_demo.md
    fi
done

# Close the demo section
echo "<!-- END DEMO -->" >> temp_demo.md

# If README.md doesn't exist, create it with a basic template
if [ ! -f "README.md" ]; then
    cat << 'EOF' > README.md
# Flutter Feature Tour

A Flutter package for creating interactive feature tours and onboarding experiences.

EOF
fi

# Replace existing demo section or append new one
if grep -q "<!-- BEGIN DEMO -->" README.md; then
    # If demo section exists, replace it
    sed -i.bak '/<!-- BEGIN DEMO -->/,/<!-- END DEMO -->/!b;r temp_demo.md' README.md
    sed -i.bak '/<!-- BEGIN DEMO -->/,/<!-- END DEMO -->/d' README.md
    rm README.md.bak
else
    # If no demo section exists, append it
    cat temp_demo.md >> README.md
fi

# Clean up temporary file
rm temp_demo.md

echo "README.md demo section has been updated successfully!"