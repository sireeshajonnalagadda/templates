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

# This section verifies connectivity to rubygems.org and attempts to install a gem if reachable.
can_reach_rubygems=false
for i in 1 2 3 4 5; do
  if curl -fsSL --connect-timeout 10 --max-time 20 https://rubygems.org/ >/dev/null; then
    can_reach_rubygems=true
    break
  fi
  sleep $((i * 2))
done

if [ "${can_reach_rubygems}" = "true" ]; then
  check "user can install gems" gem install --no-document github-markup
else
  echo "WARN: Could not reach rubygems.org after retries; skipping gem install check."
fi

# Report result
reportResults
