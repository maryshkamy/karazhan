PRODUCT_NAME := Karazhan
PROJ_NAME := $(PRODUCT_NAME).xcodeproj
WORKSPACE_NAME := ${PRODUCT_NAME}.xcworkspace

BUNDLE=$(if $(rbenv > /dev/null), rbenv exec bundle, bundle)
FASTLANE=$(BUNDLE) exec fastlane

.PHONY: help
help: # Show this command list
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":[^#]*? #| #"}; {printf "%-57s%s\n", $$1 $$3, $$2}'

.PHONY: setup-homebrew
setup-homebrew: # Setup Homebrew on the machine
	brew update
	brew upgrade
	brew cleanup

.PHONY: install-rbenv
install-rbenv: # Install rbenv on the project folder
	brew install rbenv

.PHONY: setup-rbenv
setup-rbenv: # Setup rbenv on the project folder
	rbenv install -s
	rbenv exec gem install bundler

.PHONY: install-bundler
install-bundler: # Install Bundler on the machine
	sudo gem install bundler

.PHONY: setup-bundler
setup-bundler: # Setup Bundler on the project and create Gemfile
	$(BUNDLE) init
	$(MAKE) install-bundler-dependencies

.PHONY: install-bundler-dependencies
install-bundler-dependencies: # Install Bundler dependencies
	$(BUNDLE) install

.PHONY: update-bundler-dependencies
update-bundler-dependencies: # Update Bundler dependencies
	$(BUNDLE) update

.PHONY: setup-fastlane
setup-fastlane: # Setup Fastlane on the project
	echo "gem 'fastlane'" >> Gemfile
	$(MAKE) install-bundler-dependencies

.PHONY: setup
setup: # Install dependencies and prepare development configuration
	$(MAKE) setup-homebrew
	$(MAKE) install-rbenv
	$(MAKE) setup-rbenv
	# $(MAKE) install-bundler-dependencies

.PHONY: open
open: # Open xcodeproj/workspace in Xcode
	@[ -f ./${WORKSPACE_NAME} ] && open ./${WORKSPACE_NAME} || open ./${PROJ_NAME} || echo Error to open Xcode project

.PHONY: clear
clear: # Clear cache
	xcodebuild clean -alltargets
	rm -rf ./Pods
	rm -rf ./Carthage
	rm -rf ./vendor/bundle
	rm -rf ./Templates