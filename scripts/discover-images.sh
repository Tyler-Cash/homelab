#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# This script discovers all container images in the repository.
# It renders Helm charts and parses Kubernetes manifests to find image references.
# This script assumes that 'helm' and 'yq' are installed and available in the PATH.

# --- Image Discovery ---

# Temp file to store all rendered manifests
TMP_YAML=$(mktemp)
trap 'rm -f "$TMP_YAML"' EXIT

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

# 3. Extract all unique image references from the combined YAML, filtering out any empty lines
echo "--- Extracting Image References ---" >&2
cat "$TMP_YAML" | yq '.. | .image? | select(.)' | sort -u | sed '/^$/d'