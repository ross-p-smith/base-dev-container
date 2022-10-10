SHELL := /bin/bash

VERSION := 0.0.1
BUILD_INFO := Manual build

ENV_FILE := .env
ifeq ($(filter $(MAKECMDGOALS),config clean),)
	ifneq ($(strip $(wildcard $(ENV_FILE))),)
		ifneq ($(MAKECMDGOALS),config)
			include $(ENV_FILE)
			export
		endif
	endif
endif

.PHONY: help lint image push build run
.DEFAULT_GOAL := help

help: ## 💬 This help message :)
	@echo -e "\e[34m$@\e[0m" || true
	@grep -E '[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

all: bootstrap buildimage pushimage buildfunc deploy ## 🏃‍♀️ Run all the things

lint: ## 🌟 Lint & format, will not fix but sets exit code on error, use in CI
	@echo -e "\e[34m$@\e[0m" || true
	@terraform fmt -check -recursive -diff

build: ## 🔨 Run a local binary build without a container
	@echo -e "\e[34m$@\e[0m" || true
	@echo "Not implemented yet!"

run: ## 🏃 Run application, used for local development
	@echo -e "\e[34m$@\e[0m" || true
	@echo "Not implemented yet!"

test: ## 🧪 Run tests, used for local development
	@echo -e "\e[34m$@\e[0m" || true
	@echo "Not implemented yet!"

bootstrap: ## 🥾 Deploy core project resources
	@echo -e "\e[34m$@\e[0m" || true
	@./scripts/bootstrap.sh

deploy: ## 🏡 Deploy application resources
	@echo -e "\e[34m$@\e[0m" || true
	@./scripts/deploy.sh

destroy: bootstrap ## 💣 Destroy application resources
	@echo -e "\e[34m$@\e[0m" || true
	@./scripts/destroy.sh

e2e-test: ## 🤖 Run end to end tests against the API
	@figlet $@ || true
	@echo "Not implemented yet!"

clean: ## 🧹 Clean up local files
	@figlet $@ || true
	@rm -rf infra/tf/.terraform
	@rm -rf infra/tf/terraform.tfstate.*
	@rm -rf infra/tf/*.tfplan
	@rm -rf infra/tf/bootstrap_*.*
	@find ./src -type d -name 'bin' | xargs rm -rf
	@find ./src -type d -name 'obj' | xargs rm -rf
	@find ./src -name 'coverage.json' | xargs rm -rf
