# 部署文档

## 镜像仓库

**LLMs 服务：**
- **Docker Hub**: `sesiting/llms:latest`（推荐）
- **Harbor**: `harbor.blacklake.tech/ai/llms:latest`

**AI Coder 服务：**
- **Docker Hub**: `sesiting/ai-coder:latest`（推荐）
- **Harbor**: `harbor.blacklake.tech/ai/ai-coder:latest`

## 构建推送

详细构建说明请参考：
- [LLMs 构建文档](llms/DEPLOY.md)
- [AI Coder 构建文档](ai-coder/DEPLOY.md)

**快速命令：**
```bash
# 构建并推送 LLMs
docker build -t sesiting/llms:latest -f llms/Dockerfile llms/
docker push sesiting/llms:latest

# 构建并推送 AI Coder
docker build -t sesiting/ai-coder:latest -f ai-coder/Dockerfile ai-coder/
docker push sesiting/ai-coder:latest
```

## 启动脚本

### run-compose.sh 参数

| 参数 | 长参数 | 说明 | 默认值 |
|------|--------|------|--------|
| `-o` | `--org` | 组织ID | 001 |
| `-f` | `--flow` | 流程ID | 001 |
| `-p` | `--port` | 端口号 | 8000 |
| `-n` | `--name` | 项目名 | ai-flow-{ORG_ID}-{FLOW_ID} |
| `-l` | `--llms` | 是否启动内部 llms 服务 | false（可省略） |
| `-e` | `--env` | 环境配置（dev/prod） | 空（使用通用配置） |
| `-h` | `--help` | 显示帮助信息 | - |

### ai-coder/run-docker.sh 参数

| 参数 | 长参数 | 说明 | 默认值 |
|------|--------|------|--------|
| `-o` | `--org` | 组织ID | 001 |
| `-f` | `--flow` | 流程ID | 001 |
| `-p` | `--port` | 端口号 | 8000 |
| `-n` | `--name` | 容器名 | ai-coder-{ORG_ID}-{FLOW_ID} |
| `-h` | `--help` | 显示帮助信息 | - |

## 部署场景

### 1. 单租户部署（推荐）

```bash
# 开发环境部署（使用外部 llms，默认）
cat > .env << EOF
ANTHROPIC_BASE_URL=http://external-llms:3009
EOF
./run-compose.sh -o 001 -f 001 -e dev

# 生产环境部署（使用外部 llms，默认）
cat > .env << EOF
ANTHROPIC_BASE_URL=http://external-llms:3009
EOF
./run-compose.sh -o 001 -f 001 -e prod

# 使用内部 llms（开发环境）
cat > .env << EOF
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxx
EOF
./run-compose.sh -o 001 -f 001 -e dev -l true

# 使用内部 llms（生产环境）
cat > .env << EOF
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxx
EOF
./run-compose.sh -o 001 -f 001 -e prod -l true
```

### 2. 多租户部署

```bash
# 租户 1（开发环境，使用外部 llms）
./run-compose.sh -o 001 -f 001 -e dev

# 租户 1（生产环境，使用外部 llms）
./run-compose.sh -o 001 -f 001 -e prod

# 租户 2（开发环境，使用内部 llms）
./run-compose.sh -o 002 -f 001 -e dev -l true

# 租户 2（生产环境，使用内部 llms）
./run-compose.sh -o 002 -f 001 -e prod -l true

# 租户 3（开发环境，不同端口）
./run-compose.sh -o 003 -f 001 -e dev -p 8080

# 租户 3（生产环境，不同端口）
./run-compose.sh -o 003 -f 001 -e prod -p 8080
```

### 3. AI Coder 独立部署

```bash
cd ai-coder
./run-docker.sh -o 001 -f 001 -p 8000
```

## 使用场景

### 场景 1: 使用外部 llms 服务（默认）
```bash
# 开发环境（省略 -l false，默认使用外部 llms）
./run-compose.sh -o 001 -f 001 -e dev

# 生产环境（省略 -l false，默认使用外部 llms）
./run-compose.sh -o 001 -f 001 -e prod
```

### 场景 2: 启动内部 llms 服务
```bash
# 开发环境
# .env 配置: OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxx
./run-compose.sh -o 001 -f 001 -e dev -l true

# 生产环境
# .env 配置: OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxx
./run-compose.sh -o 001 -f 001 -e prod -l true
```

### 场景 3: 共享 llms 实例
```bash
# 主实例（开发环境，启动内部 llms）
./run-compose.sh -o 001 -f 001 -e dev -l true

# 主实例（生产环境，启动内部 llms）
./run-compose.sh -o 001 -f 001 -e prod -l true

# 共享实例（开发环境，使用外部 llms，连接主实例）
# .env 配置: ANTHROPIC_BASE_URL=http://llms:3000
./run-compose.sh -o 002 -f 001 -e dev

# 共享实例（生产环境，使用外部 llms，连接主实例）
# .env 配置: ANTHROPIC_BASE_URL=http://llms:3000
./run-compose.sh -o 002 -f 001 -e prod
```

### 场景 4: 多端口部署
```bash
# 开发环境多端口部署
./run-compose.sh -o 001 -f 001 -e dev -p 8001
./run-compose.sh -o 001 -f 002 -e dev -p 8002
./run-compose.sh -o 002 -f 001 -e dev -p 8003

# 生产环境多端口部署
./run-compose.sh -o 001 -f 001 -e prod -p 8001
./run-compose.sh -o 001 -f 002 -e prod -p 8002
./run-compose.sh -o 002 -f 001 -e prod -p 8003
```

## 常用命令

```bash
# 查看帮助
./run-compose.sh --help
cd ai-coder && ./run-docker.sh --help

# 查看服务状态（开发环境）
docker compose -f docker-compose.yml -p ai-flow-001-001 ps

# 查看服务状态（生产环境）
docker compose -f docker-compose.prod.yml -p ai-flow-001-001 ps

# 查看日志（开发环境）
docker compose -f docker-compose.yml -p ai-flow-001-001 logs -f

# 查看日志（生产环境）
docker compose -f docker-compose.prod.yml -p ai-flow-001-001 logs -f

# 停止服务（开发环境）
docker compose -f docker-compose.yml -p ai-flow-001-001 down

# 停止服务（生产环境）
docker compose -f docker-compose.prod.yml -p ai-flow-001-001 down

# 查看所有租户
docker ps --filter "name=ai-coder-" --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"
```

## 环境配置说明

## 环境配置说明

### 通用配置（默认）
- 使用 `docker-compose.yml` 配置文件
- 不指定 `-e` 参数时的默认选择
- 适合大多数场景

### 开发环境（dev）
- 使用 `docker-compose.dev.yml` 配置文件
- 指定 `-e dev` 时使用
- 适合开发和测试（文件预留，暂未创建）

### 生产环境（prod）
- 使用 `docker-compose.prod.yml` 配置文件
- 指定 `-e prod` 时使用
- 直接拉取预构建镜像
- 适合生产部署

## 环境变量

| 变量名 | 说明 | 示例 | 使用场景 |
|--------|------|------|----------|
| `OPENROUTER_API_KEY` | LLMs API 密钥 | `sk-or-v1-xxxxx` | 使用内部 llms 时必需 |
| `ANTHROPIC_BASE_URL` | LLMs 服务地址 | `http://llms:3000` | 使用外部 llms 时必需 |
| `ANTHROPIC_API_KEY` | Claude API Key | `custom` | 可选，默认为 custom |

## Linux 部署注意事项

### 镜像仓库访问
```bash
# 如果使用 Harbor 镜像，需要先登录
docker login harbor.blacklake.tech

# 如果使用 Docker Hub 镜像，修改 docker-compose.prod.yml 中的镜像地址
# harbor.blacklake.tech/ai/llms:latest → sesiting/llms:latest
# harbor.blacklake.tech/ai/ai-coder:latest → sesiting/ai-coder:latest
```

### 架构兼容性
- 确保镜像支持目标 Linux 架构（amd64/arm64）
- 推荐使用 Docker Hub 镜像，兼容性更好

## 端口说明

- **内部 llms**: 端口 3000
- **外部 llms**: 建议使用 3009（避免冲突）
- **ai-coder**: 端口 8000（可自定义）