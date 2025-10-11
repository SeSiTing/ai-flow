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
./start.sh

# 或者手动启动各服务
# cd llms && npm install && npm run build && npm start &
# cd ../ai-coder && uv sync && uv run api &

# 5. 验证服务
curl http://localhost:8000/status
```

### Docker 部署

```bash
# 构建镜像
docker build -t sesiting/ai-flow .

# 启动容器（指定组织和流程 ID）
docker run -d \
  --name ai-flow \
  -p 8000:8000 \
  -e ORG_ID=001 \
  -e FLOW_ID=001 \
  --env-file .env \
  sesiting/ai-flow

# 验证服务
curl http://localhost:8000/status
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

### 启动时动态参数（通过 -e 传递）

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `ORG_ID` | 组织ID（多租户隔离） | `001` |
| `FLOW_ID` | 流程ID（多租户隔离） | `001` |

**注意**：静态配置在 `.env` 文件中，动态参数通过 `docker run -e` 或命令行传递。


## 📞 支持

- 📧 邮箱: shensaiting@blacklake.cn
- 🐛 问题反馈: [GitHub Issues](https://github.com/yourusername/ai-flow/issues)

---

**🎉 开始使用 AI Flow，让编程变得更智能！**
