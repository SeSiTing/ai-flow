# 部署文档

## 镜像仓库

**LLMs 服务：** `sesiting/llms:latest` / `sesiting/llms:${tag}`  
**AI Coder 服务：** `sesiting/ai-coder:latest` / `sesiting/ai-coder:${tag}`  
**OP MCP Tools 服务：** `sesiting/op-mcp:latest` / `sesiting/op-mcp:${tag}`

## 快速构建

### 环境变量设置

```bash
# 设置版本号（修改此处即可）
export tag=1.0.0
```

```bash
# 构建并推送 LLMs（同时打两个标签）
docker build -t sesiting/llms:${tag} -t sesiting/llms:latest -f llms/Dockerfile llms/
docker push sesiting/llms:${tag}
docker push sesiting/llms:latest

# 构建并推送 AI Coder（同时打两个标签）
docker build -t sesiting/ai-coder:${tag} -t sesiting/ai-coder:latest -f ai-coder/Dockerfile ai-coder/
docker push sesiting/ai-coder:${tag}
docker push sesiting/ai-coder:latest

# 构建并推送 OP MCP Tools（同时打两个标签）
docker build -t sesiting/op-mcp:${tag} -t sesiting/op-mcp:latest -f op-mcp/Dockerfile op-mcp/
docker push sesiting/op-mcp:${tag}
docker push sesiting/op-mcp:latest
```

## 启动脚本

### run-compose.sh 命令

| 命令 | 说明 | 示例 |
|------|------|------|
| `up` | 启动服务（默认） | `./run-compose.sh up -o 001 -f 002` |
| `down` | 关闭服务 | `./run-compose.sh down -o 001 -f 002` |
| `build` | 构建镜像 | `./run-compose.sh build -o 001 -f 002` |
| `restart` | 重启服务 | `./run-compose.sh restart -o 001 -f 002` |

### 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-o, --org` | 组织ID | default |
| `-f, --flow` | 流程ID | default |
| `-p, --port` | 端口号 | 8000 |
| `-l, --llms` | 使用内部 llms | false |
| `-e, --env` | 环境配置 | docker-compose.yml |

## 部署示例

### 使用默认值（推荐）
```bash
# 使用默认值启动服务
./run-compose.sh up

# 使用默认值重启服务
./run-compose.sh restart

# 使用默认值关闭服务
./run-compose.sh down
```

### 使用外部 llms
```bash
# 开发环境
cat > .env << EOF
ANTHROPIC_BASE_URL=http://external-llms:3009
EOF
./run-compose.sh up -o 001 -f 001 -e dev

# 生产环境
./run-compose.sh up -o 001 -f 001 -e prod
```

### 使用内部 llms
```bash
# 开发环境
cat > .env << EOF
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxx
EOF
./run-compose.sh up -o 001 -f 001 -e dev -l true

# 生产环境
./run-compose.sh up -o 001 -f 001 -e prod -l true
```

### 多租户部署
```bash
# 不同组织/流程
./run-compose.sh up -o 001 -f 001 -e dev
./run-compose.sh up -o 002 -f 001 -e dev -p 8080
./run-compose.sh up -o 001 -f 002 -e dev -p 8081
```

## 常用命令

```bash
# 查看帮助
./run-compose.sh --help

# 查看服务状态（使用默认值）
docker compose -f docker-compose.yml -p ai-flow-default-default ps

# 查看日志（使用默认值）
docker compose -f docker-compose.yml -p ai-flow-default-default logs -f

# 停止服务（使用默认值）
./run-compose.sh down

# 重启服务（使用默认值）
./run-compose.sh restart

# 重新构建并重启（使用默认值）
./run-compose.sh build
./run-compose.sh restart
```

## 环境配置

| 环境 | 配置文件 | 说明 |
|------|----------|------|
| 默认 | `docker-compose.yml` | 通用配置 |
| dev | `docker-compose.dev.yml` | 开发环境 |
| prod | `docker-compose.prod.yml` | 生产环境 |

## 环境变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `OPENROUTER_API_KEY` | LLMs API 密钥 | `sk-or-v1-xxxxx` |
| `ANTHROPIC_BASE_URL` | LLMs 服务地址 | `http://llms:3000` |
| `ANTHROPIC_API_KEY` | Claude API Key | `custom` |

## OP MCP Tools 独立部署

OP MCP Tools 是一个独立的服务，提供 AI Agent 所需的工具支持。

### 独立部署

```bash
# 拉取镜像
docker pull sesiting/op-mcp:latest

# 启动服务
docker run -d \
  --name op-mcp \
  -p 8008:8008 \
  --restart unless-stopped \
  sesiting/op-mcp:latest
```

### 验证服务

```bash
# 健康检查
curl http://localhost:8008/health

# MCP Inspector UI
# 访问 http://localhost:8008/mcp
```

### 与 AI Coder 集成

OP MCP Tools 是独立的 MCP 服务提供者，需要手动配置：

1. **启动 OP MCP Tools 服务**
   ```bash
   docker run -d --name op-mcp -p 8008:8008 op-mcp:latest
   ```

2. **在 AI Coder 容器中配置 MCP**
   ```bash
   # 进入 AI Coder 容器
   docker exec -it ai-coder-001-001 bash
   
   # 配置 MCP 服务器
   claude mcp add-json op '{"type":"http","url":"http://op-mcp:8008"}'
   ```

3. **验证配置**
   ```bash
   claude mcp list
   ```

**注意**：如果 AI Coder 和 OP MCP Tools 在不同机器上，需要修改 URL 为实际的服务地址。

### 工具列表

- `execute_sql_tool`：执行 SQL 查询
- `query_api_info_tool`：查询 API 元数据
- `generate_ids_tool`：生成唯一 ID

## 端口说明

- **内部 llms**: 端口 3000
- **外部 llms**: 建议使用 3009
- **ai-coder**: 端口 8000（可自定义）
- **op-mcp**: 端口 8008