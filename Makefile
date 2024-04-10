# Copyright 2024 The Flux authors. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

# Flux hub-and-spoke
# Requirements: docker, kind, kubectl

.ONESHELL:
.SHELLFLAGS += -e

.PHONY: validate
validate: # Validate the Flux manifests
	scripts/validate.sh

.PHONY: fleet-up
fleet-up: # Start local Kind clusters (flux-hub, flux-staging and flux-production)
	scripts/fleet-up.sh

.PHONY: fleet-down
fleet-down: # Teardown the Kind clusters
	scripts/fleet-down.sh

.PHONY: help
help:  ## Display this help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
