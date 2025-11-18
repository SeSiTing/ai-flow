# AI Flow - 智能编程助手

基于 Claude Agent SDK 的智能编程助手，集成 Designer 和 Developer 两个 Agent。

## 🚀 快速开始

### 初始化项目

```bash
# 1. 克隆项目（包含 submodules）
git clone --recursive https://github.com/yourusername/ai-flow.git
cd ai-flow

# 或者已克隆项目后，更新 submodules
git submodule update --init --recursive

# 2. 更新所有 submodules 到最新版本
git submodule update --remote --recursive

# 3. 配置环境变量
cp env.example .env
# 编辑 .env 文件，填入 OPENROUTER_API_KEY 等配置
```

### 启动服务

```bash
# 使用启动脚本（推荐）
chmod +x run-compose.sh
./run-compose.sh -o 001 -f 001

# 验证服务
curl http://localhost:8000/status
```

**高级用法：**
```bash
# 使用外部 llms 服务
./run-compose.sh -o 001 -f 001 -l false

# 指定端口
./run-compose.sh -o 001 -f 001 -p 8080

# 详细文档见 DEPLOY.md
```

## 📦 Submodule 管理

项目包含以下 submodules：

- `ai-coder` - AI 编程服务
- `llms` - LLM 服务
- `op-mcp` - OP MCP 工具服务
- `claude-code-router` - Claude 代码路由服务
- `claude-agent-sdk-python` - Claude Agent SDK

### 更新 Submodules

```bash
# 更新所有 submodules 到最新版本
git submodule update --remote --recursive

# 更新特定 submodule
git submodule update --remote ai-coder

# 提交 submodule 更新
git add .gitmodules ai-coder llms op-mcp claude-code-router claude-agent-sdk-python
git commit -m "chore: update submodules"
```

## 🔐 环境配置

**必需配置 .env 文件**：

```bash
cp env.example .env
```

主要环境变量：

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `OPENROUTER_API_KEY` | OpenRouter API 密钥（必需） | `sk-or-v1-xxxxx` |
| `ANTHROPIC_BASE_URL` | LLMs 服务地址 | `http://localhost:3000` |
| `ANTHROPIC_API_KEY` | Claude API Key | `custom` |
| `MCP_SERVERS__OP__URL` | OP MCP 服务器地址 | `http://op-mcp:8008` |

启动参数（通过脚本传递）：

| 参数 | 说明 | 示例值 |
|------|------|--------|
| `-o, --org` | 组织ID | `001` |
| `-f, --flow` | 流程ID | `001` |
| `-p, --port` | 端口号 | `8000` |

## 📡 API 接口

```bash
# 查看状态
curl http://localhost:8000/status

# API 文档
open http://localhost:8000/docs
```

## 📚 文档

- [部署文档](DEPLOY.md) - 详细的部署和配置说明
- [测试文档](TESTING.md) - 测试指南

## 📞 支持

- 📧 邮箱: shensaiting@blacklake.cn
- 🐛 问题反馈: [GitHub Issues](https://github.com/yourusername/ai-flow/issues)
