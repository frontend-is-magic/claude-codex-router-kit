# Claude CLI -> CLIProxyAPI -> Codex Router Kit

This repo documents and bootstraps a local route that lets `claude` use Codex models through `CLIProxyAPI`.

## Flow

```text
Claude CLI
  -> ANTHROPIC_BASE_URL=http://127.0.0.1:8317
  -> CLIProxyAPI
  -> Codex OAuth credentials in ~/.cli-proxy-api
  -> Codex models such as gpt-5.4 / gpt-5-codex
```

## What this kit does

- Writes a local `cliproxyapi` config.
- Writes three helper scripts:
  - `start-cliproxyapi.sh`
  - `codex-login-cliproxyapi.sh`
  - `claude-via-cliproxyapi.sh`
- Optionally adds a `crclaude` shell function to `~/.zshrc`.

## Prerequisites

- macOS or Linux shell environment
- `cliproxyapi` installed and in `PATH`
- `claude` installed and in `PATH`
- ChatGPT account with Codex access

## One-time setup

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

Then run:

```bash
~/.claude-code-router/codex-login-cliproxyapi.sh
```

This opens the Codex OAuth page and writes credentials into `~/.cli-proxy-api`.

## Daily usage

```bash
~/.claude-code-router/start-cliproxyapi.sh
~/.claude-code-router/claude-via-cliproxyapi.sh
```

If you enabled the shell shortcut during bootstrap:

```bash
crclaude
crclaude -p "Reply with exactly OK"
```

## Default model mapping

- `ANTHROPIC_DEFAULT_OPUS_MODEL=gpt-5.4`
- `ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-5.4`
- `ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-5.4-mini`

Edit `~/.claude-code-router/claude-via-cliproxyapi.sh` if you want different defaults.

## Verify the route

Start the server:

```bash
curl -s http://127.0.0.1:8317/healthz
curl -s -H 'Authorization: Bearer sk-dummy' http://127.0.0.1:8317/v1/models
```

Then test end to end:

```bash
crclaude -p "Reply with exactly OK_CLIPROXY_TEST and nothing else."
```

## Notes

- This repo does not contain OAuth credentials.
- Do not commit the contents of `~/.cli-proxy-api`.
- Do not commit real API keys into config files.
