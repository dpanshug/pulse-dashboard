# OSAIPO Core Deployment Base

- Upstream repository: https://github.com/red-hat-data-services/org-pulse-core
- Upstream release: v2.0.69
- Synced by: scripts/sync-osaipo-core-base.sh

## Local transformations

- Backend image references are rewritten to `quay.io/osaipo-data/org-pulse-core-backend`.
- Frontend image references are rewritten to `quay.io/osaipo-data/org-pulse-core-frontend`.
- The chatbot deployment remains the upstream `quay.io/org-pulse/org-pulse-chatbot` image for now.

The corresponding OSAIPO core image tags must be published before this base is deployed or the dashboard image workflow is run.
