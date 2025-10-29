# AI Flow - 智能编程助手

基于 Claude Agent SDK 的智能编程助手，集成 Designer 和 Developer 两个 Agent。

## 🚀 快速开始

### 本地开发

```bash
# 1. 克隆项目
git clone https://github.com/yourusername/ai-flow.git
cd ai-flow

# 2. 配置环境变量
cp env.example .env
# 编辑 .env 文件，填入实际值

# 3. 设置动态参数（本地开发）
export ORG_ID=001
export FLOW_ID=001

# 4. 使用启动脚本（推荐）
./run-compose.sh -o 001 -f 001

# 或者手动启动各服务
# cd llms && npm install && npm run build && npm start &
# cd ../ai-coder && uv sync && uv run api &

# 5. 验证服务
curl http://localhost:8000/status
```

### Docker Compose 部署（推荐）

```bash
# 1. 配置环境变量
cp env.example .env
# 编辑 .env，填入 OPENROUTER_API_KEY

# 2. 使用启动脚本（推荐）
./run-compose.sh -o 001 -f 001

# 3. 验证服务
curl http://localhost:8000/status

# 4. 查看日志
docker-compose -p ai-flow-001-001 logs -f
```

**高级用法：**
```bash
# 使用外部 llms 服务
# .env 中配置: ANTHROPIC_BASE_URL=http://external-llms:3009
./run-compose.sh -o 001 -f 001 -l false

# 指定端口
./run-compose.sh -o 001 -f 001 -p 8080

# 详细文档见 DEPLOY.md
```

## 🔐 环境配置

**必需配置 .env 文件**，项目依赖以下环境变量：

```bash
# 复制环境变量模板
cp env.example .env

# 编辑 .env 文件
cat > .env << EOF
# Claude API 配置（必需）
ANTHROPIC_BASE_URL=http://localhost:3000
ANTHROPIC_API_KEY=custom

# 工作目录配置（必需）
PROJECT_ROOT=/app/ai-coder

# LLMs API 配置（必需）
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxx
EOF
```

**注意**：`ORG_ID` 和 `FLOW_ID` 需要在启动时通过 `-e` 参数动态传递，支持多租户场景。

## 📡 API 接口

```bash
# 查看状态
curl http://localhost:8000/status

# 发送消息
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "帮我创建一个简单的 Python 函数"}'

# API 文档
open http://localhost:8000/docs
```

## 🔧 环境变量

### .env 文件配置（静态配置）

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `ANTHROPIC_BASE_URL` | Claude API 地址（指向 LLMs 服务） | `http://localhost:3000` |
| `ANTHROPIC_API_KEY` | Claude API Key（固定值） | `custom` |
| `PROJECT_ROOT` | 工作目录根路径 | `/app/ai-coder` |
| `OPENROUTER_API_KEY` | OpenRouter API 密钥（必需） | `sk-or-v1-xxxxx` |
| `MCP_SERVERS__OP__URL` | OP MCP 服务器地址 | `http://op-mcp:8008` |

### 启动时动态参数（通过 -e 传递）

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `ORG_ID` | 组织ID（多租户隔离） | `001` |
| `FLOW_ID` | 流程ID（多租户隔离） | `001` |

**注意**：静态配置在 `.env` 文件中，动态参数通过 `docker run -e` 或命令行传递。

### MCP 服务器配置（可选）

通过环境变量配置多个 MCP 服务器，支持双下划线式层级配置：

```bash
# 最简单配置（只配置 URL，type 默认为 http）
MCP_SERVERS__OP__URL=http://op-mcp:8008

# 完整配置
MCP_SERVERS__OP__TYPE=http
MCP_SERVERS__OP__URL=http://op-mcp:8008
MCP_SERVERS__OP__HEADERS={"x-api-key":"your-key"}

# 配置多个服务器
MCP_SERVERS__CUSTOM__URL=http://custom-mcp:9000
```

详细配置说明见 [DEPLOY.md](DEPLOY.md#op-mcp-tools-独立部署)。


## 📞 支持

- 📧 邮箱: shensaiting@blacklake.cn
- 🐛 问题反馈: [GitHub Issues](https://github.com/yourusername/ai-flow/issues)

---

**🎉 开始使用 AI Flow，让编程变得更智能！**
