#!/usr/bin/env bash
# Sync the upstream deployment base into the OSAIPO-owned base.
# Usage: scripts/sync-osaipo-core-base.sh 2.0.69
set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <core-version>" >&2
  exit 2
fi
VERSION="${VERSION#v}"
TAG="v${VERSION}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$ROOT/deploy/openshift/osaipo-core-base"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ARCHIVE="$TMP_DIR/core.tar.gz"
EXTRACTED="$TMP_DIR/extracted"
mkdir -p "$EXTRACTED"

curl --fail --location --silent --show-error \
  "https://github.com/red-hat-data-services/org-pulse-core/archive/refs/tags/${TAG}.tar.gz" \
  --output "$ARCHIVE"
tar -xzf "$ARCHIVE" -C "$EXTRACTED"

SOURCE_BASE="$(find "$EXTRACTED" -type d -path '*/deploy/openshift/base' -print -quit)"
if [[ -z "$SOURCE_BASE" ]]; then
  echo "Unable to find deploy/openshift/base in ${TAG}" >&2
  exit 1
fi

rm -rf "$TARGET"
mkdir -p "$TARGET"
cp -R "$SOURCE_BASE"/. "$TARGET"/

# Keep the deployment base OSAIPO-owned. The chatbot remains an explicit
# upstream dependency because no OSAIPO chatbot repository is defined.
for file in "$TARGET/backend-deployment.yaml" "$TARGET/frontend-deployment.yaml" "$TARGET/kustomization.yaml"; do
  sed -i.bak \
    -e 's#quay.io/org-pulse/org-pulse-core-backend#quay.io/osaipo-data/org-pulse-core-backend#g' \
    -e 's#quay.io/org-pulse/org-pulse-core-frontend#quay.io/osaipo-data/org-pulse-core-frontend#g' \
    "$file"
  rm -f "$file.bak"
done
printf '%s\n' "$TAG" > "$TARGET/CORE_VERSION"
cat > "$TARGET/UPSTREAM.md" <<EOF
# OSAIPO Core Deployment Base

- Upstream repository: https://github.com/red-hat-data-services/org-pulse-core
- Upstream release: ${TAG}
- Synced by: scripts/sync-osaipo-core-base.sh

## Local transformations

- Backend image references are rewritten to \`quay.io/osaipo-data/org-pulse-core-backend\`.
- Frontend image references are rewritten to \`quay.io/osaipo-data/org-pulse-core-frontend\`.
- The chatbot deployment remains the upstream \`quay.io/org-pulse/org-pulse-chatbot\` image for now.

The corresponding OSAIPO core image tags must be published before this base is deployed or the dashboard image workflow is run.
EOF

echo "Synchronized OSAIPO core base to ${TAG}"
