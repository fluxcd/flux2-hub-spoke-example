#!/usr/bin/env bash

# This script creates a fleet of Kubernetes clusters using kind.

# Copyright 2024 The Flux authors. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

# Prerequisites
# - docker v25.0
# - kind v0.22
# - kubectl v1.29

set -o errexit
set -o pipefail

repo_root=$(git rev-parse --show-toplevel)
mkdir -p "${repo_root}/bin"

CLUSTER_VERSION="${CLUSTER_VERSION:=v1.29.2}"

CLUSTER_HUB="flux-hub"
echo "INFO - Creating cluster ${CLUSTER_HUB}"

kind create cluster --name "${CLUSTER_HUB}" \
--image "kindest/node:${CLUSTER_VERSION}" \
--wait 5m

CLUSTER_STAGING="flux-staging"
echo "INFO - Creating cluster ${CLUSTER_STAGING}"

kind create cluster --name "${CLUSTER_STAGING}" \
--image "kindest/node:${CLUSTER_VERSION}" \
--wait 5m

CLUSTER_PRODUCTION="flux-production"
echo "INFO - Creating cluster ${CLUSTER_PRODUCTION}"

kind create cluster --name "${CLUSTER_PRODUCTION}" \
--image "kindest/node:${CLUSTER_VERSION}" \
--wait 5m

echo "INFO - Creating kubeconfig secrets in the hub cluster"

kubectl config use-context "kind-${CLUSTER_HUB}"

kind get kubeconfig --internal --name ${CLUSTER_STAGING} > "${repo_root}/bin/staging.kubeconfig"
kubectl --context "kind-${CLUSTER_HUB}" create ns staging
kubectl --context "kind-${CLUSTER_HUB}" create secret generic -n staging cluster-kubeconfig \
--from-file=value="${repo_root}/bin/staging.kubeconfig"

kind get kubeconfig --internal --name ${CLUSTER_PRODUCTION} > "${repo_root}/bin/production.kubeconfig"
kubectl --context "kind-${CLUSTER_HUB}" create ns production
kubectl --context "kind-${CLUSTER_HUB}" create secret generic -n production cluster-kubeconfig \
--from-file=value="${repo_root}/bin/production.kubeconfig"

echo "INFO - Clusters created successfully"
