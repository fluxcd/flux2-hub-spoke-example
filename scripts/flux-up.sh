#!/usr/bin/env bash

# This script configures Flux on the hub cluster.

# Copyright 2024 The Flux authors. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o pipefail

repo_root=$(git rev-parse --show-toplevel)
mkdir -p "${repo_root}/bin"

CLUSTER_HUB="flux-hub"

echo "INFO - Installing Flux in the hub cluster"

flux --context "kind-${CLUSTER_HUB}" install \
--components-extra=image-reflector-controller,image-automation-controller

flux --context "kind-${CLUSTER_HUB}" create source git flux-system \
--url=https://github.com/fluxcd/flux2-hub-spoke-example \
--ignore-paths="hub/flux-system/" \
--branch=main \
--interval=1m \
--username=git \
--password=${GITHUB_TOKEN}

flux --context "kind-${CLUSTER_HUB}" create kustomization flux-system \
--source=GitRepository/flux-system \
--path="./hub" \
--prune=true \
--interval=10m

echo "INFO - Flux configured successfully"
