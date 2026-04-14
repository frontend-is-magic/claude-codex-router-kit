# Routing Flow Summary

## Goal

Make `claude` use Codex-hosted models locally without changing the Claude CLI binary itself.

## Components

### 1. `claude`

`claude` still thinks it is talking to an Anthropic-compatible backend.

### 2. `claude-via-cliproxyapi.sh`

This wrapper injects:

- `ANTHROPIC_BASE_URL=http://127.0.0.1:8317`
- `ANTHROPIC_AUTH_TOKEN=sk-dummy`
- default model env vars pointing to Codex-backed model IDs

So every Claude CLI request goes to the local proxy first.

### 3. `cliproxyapi`

`CLIProxyAPI` exposes a Claude-compatible endpoint at:

- `POST /v1/messages`
- `GET /v1/models`

It reads:

- config from `~/.claude-code-router/cliproxyapi-config.yaml`
- OAuth credentials from `~/.cli-proxy-api`

### 4. Codex OAuth

`cliproxyapi -codex-login` performs OAuth in a browser and stores a local JSON credential file under `~/.cli-proxy-api`.

Without this step:

- `GET /v1/models` returns an empty list
- Claude requests cannot be routed to Codex

### 5. Codex model selection

Once the credential exists, `CLIProxyAPI` loads Codex models such as:

- `gpt-5.4`
- `gpt-5.4-mini`
- `gpt-5-codex`
- `gpt-5-codex-medium`

The wrapper script decides which of these is used by default.

## Runtime path

```text
crclaude
  -> start-cliproxyapi.sh  # only if local proxy is not already running
  -> claude-via-cliproxyapi.sh
  -> Claude CLI sends /v1/messages to 127.0.0.1:8317
  -> CLIProxyAPI authenticates and forwards through Codex OAuth credentials
  -> Codex model answers
  -> response flows back to Claude CLI
```

## Minimum commands

```bash
./bootstrap.sh
source ~/.zshrc
~/.claude-code-router/codex-login-cliproxyapi.sh
crclaude
```
