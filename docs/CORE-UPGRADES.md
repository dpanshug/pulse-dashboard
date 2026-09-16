# OSAIPO Core Upgrades

The dashboard keeps an OSAIPO-owned copy of the core OpenShift deployment base at
`deploy/openshift/osaipo-core-base`. The source release is recorded in
`CORE_VERSION` and `UPSTREAM.md`.

## Required image contract

Before accepting a core upgrade, the matching version must be published in Quay:

- `quay.io/osaipo-data/org-pulse-core-backend:vX.Y.Z`
- `quay.io/osaipo-data/org-pulse-core-frontend:vX.Y.Z`
- `quay.io/osaipo-data/osaipo-pulse-frontend-builder:vX.Y.Z`
- `quay.io/osaipo-data/osaipo-pulse-frontend-runtime:vX.Y.Z`

The OSAIPO dashboard workflow consumes these images and publishes the resulting
backend and frontend images to the same `osaipo-data` organization.

## Controlled update flow

1. Publish the four OSAIPO core images for the upstream `@org-pulse/core` version.
2. Run `scripts/sync-osaipo-core-base.sh X.Y.Z` when testing locally, or let the
   scheduled `Core Upgrade` workflow run.
3. The workflow updates `@org-pulse/core`, refreshes the vendored deployment base,
   verifies all four Quay tags, and renders the production Kustomize overlay.
4. The workflow opens a pull request. Review the generated base changes and CI
   before merging.
5. After merge, run the image build workflow and verify the immutable dashboard
   image tags before changing GitOps.

The sync script intentionally preserves the upstream chatbot deployment for now;
chatbot ownership is out of scope for this migration.
