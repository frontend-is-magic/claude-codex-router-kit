# Claude CLI -> CLIProxyAPI -> Codex 路由套件

这个仓库用于复现一条本地路由，让 `claude` 通过 `CLIProxyAPI` 使用 Codex 模型。

## 路由流程

```text
Claude CLI
  -> ANTHROPIC_BASE_URL=http://127.0.0.1:8317
  -> CLIProxyAPI
  -> ~/.cli-proxy-api 中的 Codex OAuth 凭证
  -> gpt-5.4 / gpt-5-codex 等模型
```

## 这个仓库会做什么

- 生成本地 `cliproxyapi` 配置
- 生成 3 个辅助脚本
  - `start-cliproxyapi.sh`
  - `codex-login-cliproxyapi.sh`
  - `claude-via-cliproxyapi.sh`
- 可选地把 `crclaude` 启动函数追加到 `~/.zshrc`

## 前置条件

- macOS 或 Linux shell 环境
- 已安装 `cliproxyapi`
- 已安装 `claude`
- 具备 Codex 权限的 ChatGPT 账号

## 一次性初始化

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

初始化后执行：

```bash
~/.claude-code-router/codex-login-cliproxyapi.sh
```

这一步会打开浏览器完成 Codex OAuth，并把凭证写入 `~/.cli-proxy-api`。

## 日常使用

```bash
~/.claude-code-router/start-cliproxyapi.sh
~/.claude-code-router/claude-via-cliproxyapi.sh
```

如果初始化时已经写入 `crclaude`，也可以直接：

```bash
crclaude
crclaude -p "Reply with exactly OK"
```

## 默认模型映射

- `ANTHROPIC_DEFAULT_OPUS_MODEL=gpt-5.4`
- `ANTHROPIC_DEFAULT_SONNET_MODEL=gpt-5.4`
- `ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-5.4-mini`

如果你想改默认模型，编辑：

- `~/.claude-code-router/claude-via-cliproxyapi.sh`

## 验证路由是否正常

启动服务后执行：

```bash
curl -s http://127.0.0.1:8317/healthz
curl -s -H 'Authorization: Bearer sk-dummy' http://127.0.0.1:8317/v1/models
```

然后做一次端到端测试：

```bash
crclaude -p "Reply with exactly OK_CLIPROXY_TEST and nothing else."
```

## 注意事项

- 这个仓库不会包含 OAuth 凭证
- 不要提交 `~/.cli-proxy-api` 里的内容
- 不要把真实 API key 提交到配置文件
