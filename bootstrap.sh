#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${HOME}/.claude-code-router"
AUTH_DIR="${HOME}/.cli-proxy-api"

if ! command -v cliproxyapi >/dev/null 2>&1; then
  echo "cliproxyapi not found in PATH"
  echo "Install it first, for example: brew install cliproxyapi"
  exit 1
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "claude not found in PATH"
  exit 1
fi

mkdir -p "${ROOT_DIR}"
mkdir -p "${AUTH_DIR}"

cat > "${ROOT_DIR}/cliproxyapi-config.yaml" <<'EOF'
host: "127.0.0.1"
port: 8317

auth-dir: "~/.cli-proxy-api"

api-keys:
  - "sk-dummy"

debug: true
logging-to-file: false
usage-statistics-enabled: false
request-retry: 3

oauth-model-alias:
  codex:
    - name: "gpt-5"
      alias: "gpt-5-high"
      fork: true
    - name: "gpt-5"
      alias: "gpt-5-medium"
      fork: true
    - name: "gpt-5"
      alias: "gpt-5-minimal"
      fork: true
    - name: "gpt-5-codex"
      alias: "gpt-5-codex-high"
      fork: true
    - name: "gpt-5-codex"
      alias: "gpt-5-codex-medium"
      fork: true
    - name: "gpt-5-codex"
      alias: "gpt-5-codex-low"
      fork: true
EOF

cat > "${ROOT_DIR}/start-cliproxyapi.sh" <<'EOF'
#!/usr/bin/env zsh
set -euo pipefail

cd "$HOME/.claude-code-router"
exec cliproxyapi -config "$HOME/.claude-code-router/cliproxyapi-config.yaml"
EOF

cat > "${ROOT_DIR}/codex-login-cliproxyapi.sh" <<'EOF'
#!/usr/bin/env zsh
set -euo pipefail

cd "$HOME/.claude-code-router"
exec cliproxyapi -config "$HOME/.claude-code-router/cliproxyapi-config.yaml" -codex-login "$@"
EOF

cat > "${ROOT_DIR}/claude-via-cliproxyapi.sh" <<'EOF'
#!/usr/bin/env zsh
set -euo pipefail

export ANTHROPIC_BASE_URL="http://127.0.0.1:8317"
export ANTHROPIC_AUTH_TOKEN="sk-dummy"
export ANTHROPIC_DEFAULT_OPUS_MODEL="gpt-5.4"
export ANTHROPIC_DEFAULT_SONNET_MODEL="gpt-5.4"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="gpt-5.4-mini"

exec claude "$@"
EOF

chmod +x \
  "${ROOT_DIR}/start-cliproxyapi.sh" \
  "${ROOT_DIR}/codex-login-cliproxyapi.sh" \
  "${ROOT_DIR}/claude-via-cliproxyapi.sh"

if ! grep -q 'crclaude()' "${HOME}/.zshrc" 2>/dev/null; then
  cat >> "${HOME}/.zshrc" <<'EOF'

# Claude CLI via local CLIProxyAPI -> Codex
crclaude() {
  if ! curl -fsS http://127.0.0.1:8317/healthz >/dev/null 2>&1; then
    nohup "$HOME/.claude-code-router/start-cliproxyapi.sh" >/tmp/cliproxyapi.log 2>&1 &
    sleep 1
  fi
  "$HOME/.claude-code-router/claude-via-cliproxyapi.sh" "$@"
}
EOF
  echo "Added crclaude() to ~/.zshrc"
else
  echo "crclaude() already exists in ~/.zshrc"
fi

echo
echo "Bootstrap complete."
echo "Next:"
echo "  1. source ~/.zshrc"
echo "  2. ~/.claude-code-router/codex-login-cliproxyapi.sh"
echo "  3. crclaude"
