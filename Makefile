# Makefile for managing Helm charts in the ziplinee-ci repository

# Variables

## Git repository name
ZIPLINEE_GIT_NAME := ziplinee-ci
## Subdirectory containing Helm charts
HELM_SUB_DIRECTORY := helm
##
ZIPLINEE_BUILD_VERSION := 1.0.0

# Use bash for advanced scripting
SHELL := /bin/bash

##@ Quality Checks

.PHONY: lint
lint: ## 🔍 Lint the Helm charts with subcharts
	@echo "Running linters on: $(HELM_SUB_DIRECTORY)/$(ZIPLINEE_GIT_NAME)"
	@test -d "$(HELM_SUB_DIRECTORY)/$(ZIPLINEE_GIT_NAME)" || { echo "Error: Chart directory '$(HELM_SUB_DIRECTORY)/$(ZIPLINEE_GIT_NAME)' not found."; exit 1; }
	@helm lint --with-subcharts "$(HELM_SUB_DIRECTORY)/$(ZIPLINEE_GIT_NAME)"

##@ Packages
.PHONY: package
package: ## 📦 Package the Helm charts with subcharts
	@echo "Packaging charts in: $(HELM_SUB_DIRECTORY)/$(ZIPLINEE_GIT_NAME)"
	@test -d "$(HELM_SUB_DIRECTORY)/$(ZIPLINEE_GIT_NAME)" || { echo "Error: Chart directory '$(HELM_SUB_DIRECTORY)/$(ZIPLINEE_GIT_NAME)' not found."; exit 1; }
	@helm package --app-version $(ZIPLINEE_BUILD_VERSION) --version $(ZIPLINEE_BUILD_VERSION) --dependency-update "$(HELM_SUB_DIRECTORY)/$(ZIPLINEE_GIT_NAME)"

##@ Publish

.PHONY: publish-chart
publish-chart: package ## 📦 Copy and index the packaged Helm chart into the charts repository
	@echo "Publishing chart to: ../ziplinee-helm-charts/charts"

	@test -f "$(ZIPLINEE_GIT_NAME)-$(ZIPLINEE_BUILD_VERSION).tgz" || \
	{ echo "Error: Packaged chart not found: $(ZIPLINEE_GIT_NAME)-$(ZIPLINEE_BUILD_VERSION).tgz"; exit 1; }

	@mkdir -p ../ziplinee-helm-charts/charts

	@cp "$(ZIPLINEE_GIT_NAME)-$(ZIPLINEE_BUILD_VERSION).tgz" ../ziplinee-helm-charts/charts/

	@helm repo index  ../ziplinee-helm-charts --url "https://helm-ziplineeci.malsharbaji.com"

	@echo "Chart published and index updated."

.PHONY: push-chart-repo
push-chart-repo: publish-chart ## 🚀 Push the charts repo (ziplinee-helm-charts) to GitHub Pages
	@echo "Pushing chart repo to GitHub Pages..."
	@cd ../ziplinee-helm-charts && \
	git add . && \
	git commit -m "Add/update $(ZIPLINEE_GIT_NAME) chart version $(ZIPLINEE_BUILD_VERSION)" && \
	git push

.PHONY: help
help: ## 📖 Show help for each Makefile target
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} \
	/^[a-zA-Z0-9_-]+:.*##/ { \
		printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 \
	} /^##@/ { \
		printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	}' $(MAKEFILE_LIST)