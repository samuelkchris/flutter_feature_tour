#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display error and exit
error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to display success
success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to display warning
warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Function to increment version
increment_version() {
    local version=$1
    local position=$2

    IFS='.' read -ra VERSION_PARTS <<< "$version"

    case $position in
        "major")
            ((VERSION_PARTS[0]++))
            VERSION_PARTS[1]=0
            VERSION_PARTS[2]=0
            ;;
        "minor")
            ((VERSION_PARTS[1]++))
            VERSION_PARTS[2]=0
            ;;
        "patch")
            ((VERSION_PARTS[2]++))
            ;;
        *)
            error "Invalid version position. Use major, minor, or patch"
            ;;
    esac

    echo "${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.${VERSION_PARTS[2]}"
}

# Check if running in the correct directory
if [ ! -f "pubspec.yaml" ]; then
    error "pubspec.yaml not found. Are you in the package root directory?"
fi

# Parse command line arguments
VERSION_TYPE=""
SKIP_CHECKS=false
DRY_RUN=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --major|--minor|--patch) VERSION_TYPE="${1:2}"; shift ;;
        --skip-checks) SKIP_CHECKS=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        *) error "Unknown parameter: $1" ;;
    esac
done

if [ -z "$VERSION_TYPE" ]; then
    error "Version type not specified. Use --major, --minor, or --patch"
fi

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep '^version: ' pubspec.yaml | cut -d ' ' -f 2)
if [ -z "$CURRENT_VERSION" ]; then
    error "Could not find current version in pubspec.yaml"
fi

# Calculate new version
NEW_VERSION=$(increment_version "$CURRENT_VERSION" "$VERSION_TYPE")
success "Preparing to update from v${CURRENT_VERSION} to v${NEW_VERSION}"

# Run checks if not skipped
if [ "$SKIP_CHECKS" = false ]; then
    echo "Running pre-deployment checks..."

    # Run the pre-push checks
    ./tool/pre_push.sh
    if [ $? -ne 0 ]; then
        error "Pre-deployment checks failed"
    fi
fi

# Update version in files
if [ "$DRY_RUN" = false ]; then
    # Update pubspec.yaml
    sed -i.bak "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
    rm pubspec.yaml.bak

    # Create new CHANGELOG entry
    TEMP_FILE=$(mktemp)
    echo -e "## $NEW_VERSION\n" > "$TEMP_FILE"
    cat CHANGELOG.md >> "$TEMP_FILE"
    mv "$TEMP_FILE" CHANGELOG.md

    # Open CHANGELOG.md for editing
    if command -v nano >/dev/null 2>&1; then
        nano CHANGELOG.md
    elif command -v vim >/dev/null 2>&1; then
        vim CHANGELOG.md
    else
        warning "No editor found. Please update CHANGELOG.md manually"
    fi

    # Git operations
    git add pubspec.yaml CHANGELOG.md
    git commit -m "chore: bump version to $NEW_VERSION"
    git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"

    # Publish to pub.dev
    echo "Publishing to pub.dev..."
    flutter pub publish

    if [ $? -eq 0 ]; then
        # Push to remote if publish successful
        git push origin main
        git push origin "v$NEW_VERSION"

        success "Successfully deployed version $NEW_VERSION!"
        success "Don't forget to create a GitHub release for v$NEW_VERSION"
    else
        error "Failed to publish to pub.dev"
    fi
else
    success "Dry run completed. No changes made."
fi