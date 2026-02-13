#!/bin/bash
cd $(dirname "$0")

source test-utils.sh vscode

# Remote - Containers does not auto-sync UID/GID for Docker Compose,
# so make sure test project prvs match the non-root user in the container.
fixTestProjectFolderPrivs

# Run common tests
checkCommon


# Run devcontainer specific tests
check "rails" rails --version
check "rails installation path" gem which rails
check "user has write permission to rvm gems" [ -w /usr/local/rvm/gems ]
check "user has write permission to rvm gems default" [ -w /usr/local/rvm/gems/default ]
# Check if we can reach rubygems.org before proceeding.
# This uses curl to silently (-s) make a request to https://rubygems.org
# Redirects output to /dev/null because we only care if the request succeeds, not the result itself.
if ! curl -s https://rubygems.org > /dev/null; then
  echo "Network access to rubygems.org is unavailable. Please check network or proxy settings."
  exit 1
fi
check "user can install gems" gem install github-markup

# Report result
reportResults
