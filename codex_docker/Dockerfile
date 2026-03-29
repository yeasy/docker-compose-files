FROM node:22-bookworm-slim

ARG CODEX_VERSION=latest

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/coder \
    CODEX_HOME=/home/coder/.codex \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_FUND=false

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        git \
        less \
        openssh-client \
        procps \
        ripgrep \
        tini \
    && rm -rf /var/lib/apt/lists/*

RUN npm install --global "@openai/codex@${CODEX_VERSION}" \
    && npm cache clean --force

RUN mkdir -p /home/coder/.codex /workspace \
    && chmod 0777 /home/coder /home/coder/.codex /workspace

WORKDIR /workspace

ENTRYPOINT ["/usr/bin/tini", "--", "codex"]
