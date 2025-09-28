#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# This script discovers all container images in the repository.
# It renders Helm charts and parses Kubernetes manifests to find image references.
# This script assumes that 'helm' and 'yq' are installed and available in the PATH.

# The first argument is the path to the temporary file for storing rendered YAML.
TMP_YAML=$1
if [ -z "$TMP_YAML" ]; then
    echo "Error: Temporary file path not provided." >&2
    exit 1
fi

# --- Image Discovery ---

# Clear the temp file to start fresh
> "$TMP_YAML"

# 1. Find and render all Helm charts
echo "--- Rendering Helm Charts ---" >&2
find kubernetes/helm -name Chart.yaml | while read -r chart_file; do
    chart_dir=$(dirname "$chart_file")
    echo "Rendering chart in $chart_dir" >&2

    # Update dependencies first to fetch any required sub-charts
    helm dependency update "$chart_dir" >&2

    # Render the chart and append to the temp file
    helm template "$chart_dir" --values "$chart_dir/values.yaml" >> "$TMP_YAML"
done

# 2. Find and append all plain Kubernetes manifests' content
echo "--- Finding and appending Kubernetes Manifests ---" >&2
find kubernetes/manifests \( -name "*.yaml" -o -name "*.yml" \) -exec cat {} + >> "$TMP_YAML"

# 3. Extract all unique image references from the combined YAML, filtering out any invalid lines
echo "--- Extracting Image References ---" >&2
# The pipeline below is designed to be robust against unexpected output from helm/yq.
# - yq extracts image fields.
# - awk '{print $1}' extracts the first word, ignoring leading whitespace and subsequent text.
# - tr -d ',"' removes any stray quotes or commas.
# - grep '[a-zA-Z]' ensures the line contains letters, filtering out garbage like '---' or '-'.
# - sort -u provides the final unique list.
cat "$TMP_YAML" | yq '.. | .image? | select(.)' | awk '{print $1}' | tr -d ',"' | grep '[a-zA-Z]' | sort -u