# Base image for the Watt Upptime Cloud Agent environment.
#
# The @upptime/uptime-monitor package ships a bundled native "node-libcurl"
# binding compiled for Node.js 24's ABI (the GitHub Action declares
# `using: node24`), so the toolchain must run on Node 24.
FROM node:24-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

USER node
