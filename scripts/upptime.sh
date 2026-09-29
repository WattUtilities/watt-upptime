#!/usr/bin/env bash
#
# Local runner for the @upptime/uptime-monitor GitHub Action.
#
# The upstream package ships as a GitHub Action whose entry point reads the
# command from the INPUT_COMMAND environment variable and authenticates with a
# GitHub token. This wrapper reproduces that contract locally so the same
# commands used in CI (update, response-time, graphs, readme, site) can be run
# during development.
#
# Usage: ./scripts/upptime.sh <command>   (defaults to "update")
set -euo pipefail

cd "$(dirname "$0")/.."

# Derive the "owner/repo" slug from the git remote unless it is already set.
if [ -z "${GITHUB_REPOSITORY:-}" ]; then
  GITHUB_REPOSITORY="$(git remote get-url origin 2>/dev/null \
    | sed -E 's#.*github\.com[:/]+([^/]+/[^/.]+)(\.git)?$#\1#')"
fi
export GITHUB_REPOSITORY

# Resolve a GitHub token. Prefer an explicit GH_PAT, then GITHUB_TOKEN, then the
# GitHub CLI token, and finally any token embedded in the git remote URL (Cloud
# Agents check out with an "x-access-token:<token>@github.com" remote).
if [ -z "${GH_PAT:-}" ]; then
  GH_PAT="${GITHUB_TOKEN:-}"
fi
if [ -z "${GH_PAT:-}" ] && command -v gh >/dev/null 2>&1; then
  GH_PAT="$(gh auth token 2>/dev/null || true)"
fi
if [ -z "${GH_PAT:-}" ]; then
  GH_PAT="$(git remote get-url origin 2>/dev/null \
    | sed -nE 's#https://x-access-token:([^@]+)@github\.com/.*#\1#p')"
fi
export GH_PAT

if [ -z "${GH_PAT:-}" ]; then
  echo "error: no GitHub token available." >&2
  echo "Set GH_PAT or authenticate the GitHub CLI with 'gh auth login'." >&2
  exit 1
fi

if [ -z "${GITHUB_REPOSITORY:-}" ]; then
  echo "error: unable to determine GITHUB_REPOSITORY (owner/repo)." >&2
  exit 1
fi

export INPUT_COMMAND="${1:-update}"
exec node node_modules/@upptime/uptime-monitor/dist/index.js
