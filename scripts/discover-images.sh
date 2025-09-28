#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# This script discovers all container images in the repository.
# It renders Helm charts and parses Kubernetes manifests to find image references.

# Ensure yq is installed
if ! command -v yq &> /dev/null
then
    echo "yq could not be found, installing..."
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
fi

# Ensure helm is installed
if ! command -v helm &> /dev/null
then
    echo "helm could not be found, please install it."
    exit 1
fi


# --- Image Discovery ---

# Temp file to store all rendered manifests
TMP_YAML=$(mktemp)
trap 'rm -f "$TMP_YAML"' EXIT

# 1. Find and render all Helm charts
echo "--- Rendering Helm Charts ---"
find kubernetes/helm -name Chart.yaml | while read -r chart_file; do
    chart_dir=$(dirname "$chart_file")
    echo "Rendering chart in $chart_dir"

    # Build dependencies first
    helm dependency build "$chart_dir" --quiet || echo "No dependencies for $chart_dir"

    # Render the chart
    helm template "$chart_dir" --values "$chart_dir/values.yaml" >> "$TMP_YAML"
done

# 2. Find all plain Kubernetes manifests
echo "--- Finding Kubernetes Manifests ---"
find kubernetes/manifests -name "*.yaml" -o -name "*.yml" >> "$TMP_YAML"

# 3. Extract all unique image references from the combined YAML
echo "--- Extracting Image References ---"
cat "$TMP_YAML" | yq '.. | .image? | select(.)' | sort -u