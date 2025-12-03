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

# 更新 submodule 并自动合并本地修改
git submodule update --remote --merge

# 提交 submodule 更新
git add .gitmodules ai-coder llms op-mcp claude-code-router claude-agent-sdk-python
git commit -m "chore: update submodules"
```

### 修复缺失的 Submodules

当 submodule 目录为空或缺失时：

```bash
# 初始化并拉取所有缺失的 submodules
git submodule update --init --recursive

# 修复特定缺失的 submodule
git submodule update --init ai-coder

# 完全重新同步 submodules（清理并重新克隆）
git submodule sync --recursive
git submodule update --init --recursive --force

# 检查 submodule 状态
git submodule status
```

### 常见问题处理

```bash
# 1. Submodule 显示为 modified 但没有实际修改
# 重置 submodule 到记录的提交
git submodule update --recursive

# 2. Submodule 版本冲突
# 先更新主项目，再更新 submodules
git pull
git submodule update --init --recursive

# 3. 清理未使用的 submodule
# 先从 .gitmodules 删除相关配置，然后：
git submodule deinit -f <path>
git rm -f <path>
rm -rf .git/modules/<path>
```

### 添加新 Submodule

```bash
# 添加新的 submodule（会自动更新 .gitmodules 和添加到索引）
git submodule add -b <branch> <repository-url> <path>

# 示例：添加 claude-agent-sdk-python
git submodule add -b main git@github.com:SeSiTing/claude-agent-sdk-python.git claude-agent-sdk-python

git submodule add -b dev git@gitlab.blacklake.tech:daas/op-agent.git op-agent

# 提交新添加的 submodule
git add .gitmodules claude-agent-sdk-python
git commit -m "chore: add claude-agent-sdk-python submodule"
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
