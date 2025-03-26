#!/bin/bash

# Script to increment the patch version in Chart.yaml
# Usage: bump-chart-version.sh <chart-dir>

set -e

CHART_DIR=$1
CHART_YAML="${CHART_DIR}/Chart.yaml"

if [[ ! -f "$CHART_YAML" ]]; then
  echo "Chart.yaml not found at ${CHART_YAML}"
  exit 1
fi

# Extract current version
CURRENT_VERSION=$(grep -E '^version:' "$CHART_YAML" | sed -E 's/version: "?([0-9]+\.[0-9]+\.[0-9]+)"?/\1/')

if [[ -z "$CURRENT_VERSION" ]]; then
  echo "Could not determine current version from ${CHART_YAML}"
  exit 1
fi

# Split version into components
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# Increment patch version
NEW_PATCH=$((PATCH + 1))
NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}"

echo "Updating chart version from ${CURRENT_VERSION} to ${NEW_VERSION}"

# Update the version in Chart.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
  # MacOS sed
  sed -i '' -E "s/version: \"?${CURRENT_VERSION}\"?/version: \"${NEW_VERSION}\"/" "$CHART_YAML"
else
  # Linux sed
  sed -i -E "s/version: \"?${CURRENT_VERSION}\"?/version: \"${NEW_VERSION}\"/" "$CHART_YAML"
fi

echo "Chart version updated successfully" 