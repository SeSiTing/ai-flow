# 部署文档

本文档包含两种部署方案：
- **方案一**：单镜像部署（快速上线）
- **方案二**：多镜像 + docker-compose 编排（推荐，支持独立更新）

---

## 方案一：单镜像部署

### 构建推送

```bash
# 登录
docker login harbor.blacklake.tech

# 构建推送
docker build -t harbor.blacklake.tech/ai/ai-flow:latest .
docker push harbor.blacklake.tech/ai/ai-flow:latest
```

## 服务器部署

### 准备 .env 文件

```bash
# 创建 .env 文件（静态配置）
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

**注意**：`ORG_ID` 和 `FLOW_ID` 是动态参数，需要在启动容器时通过 `-e` 传递。

### 启动服务

```bash
# 登录拉取
docker login harbor.blacklake.tech
docker pull harbor.blacklake.tech/ai/ai-flow:latest

# 方式 1：使用 .env 文件 + 动态参数（推荐）
docker run -d \
  --name ai-flow \
  -p 8000:8000 \
  -e ORG_ID=001 \
  -e FLOW_ID=001 \
  --env-file .env \
  harbor.blacklake.tech/ai/ai-flow:latest

# 方式 2：命令行指定所有环境变量
docker run -d \
  --name ai-flow \
  -p 8000:8000 \
  -e ANTHROPIC_BASE_URL=http://localhost:3000 \
  -e ANTHROPIC_API_KEY=custom \
  -e PROJECT_ROOT=/app/ai-coder \
  -e OPENROUTER_API_KEY=sk-or-v1-xxxxx \
  -e ORG_ID=001 \
  -e FLOW_ID=001 \
  harbor.blacklake.tech/ai/ai-flow:latest
```

## 多实例部署

```bash
# 实例 1
docker run -d --name ai-flow-001-001 -p 8001:8000 -e ORG_ID=001 -e FLOW_ID=001 --env-file .env harbor.blacklake.tech/ai/ai-flow:latest

# 实例 2
docker run -d --name ai-flow-001-002 -p 8002:8000 -e ORG_ID=001 -e FLOW_ID=002 --env-file .env harbor.blacklake.tech/ai/ai-flow:latest

# 批量部署脚本
for i in {1..5}; do
  port=$((8000 + i))
  flow=$(printf "%03d" $i)
  docker run -d \
    --name ai-flow-001-${flow} \
    -p ${port}:8000 \
    -e ORG_ID=001 \
    -e FLOW_ID=${flow} \
    --env-file .env \
    harbor.blacklake.tech/ai/ai-flow:latest
done
```

### 常用命令

```bash
# 查看状态
curl http://localhost:8000/status

# 查看日志
docker logs -f ai-flow

# 重启
docker restart ai-flow

# 停止删除
docker stop ai-flow && docker rm ai-flow

# 查看所有实例
docker ps --filter "name=ai-flow-*"

# 更新镜像
docker pull harbor.blacklake.tech/ai/ai-flow:latest
docker stop ai-flow && docker rm ai-flow
docker run -d --name ai-flow -p 8000:8000 --env-file .env harbor.blacklake.tech/ai/ai-flow:latest

# 批量停止
docker ps --filter "name=ai-flow-*" --format "{{.Names}}" | xargs docker stop

# 清理
docker image prune -f
```

---

## 方案二：多镜像 + docker-compose 编排（推荐）

### 构建推送

```bash
# 登录
docker login harbor.blacklake.tech

# 构建并推送 llms 镜像
docker build -t harbor.blacklake.tech/ai/llms:latest -f llms/Dockerfile llms/
docker push harbor.blacklake.tech/ai/llms:latest

# 构建并推送 ai-coder 镜像
docker build -t harbor.blacklake.tech/ai/ai-coder:latest -f ai-coder/Dockerfile ai-coder/
docker push harbor.blacklake.tech/ai/ai-coder:latest
```

### 准备 .env 文件

```bash
# 创建 .env 文件
cat > .env << EOF
# LLMs API 配置（必需）
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxx

# Claude API 配置
ANTHROPIC_API_KEY=custom

# 注意：ORG_ID、FLOW_ID、PORT 在启动时通过环境变量传递
EOF
```

### 单个租户部署

```bash
# 拉取镜像
docker pull harbor.blacklake.tech/ai/llms:latest
docker pull harbor.blacklake.tech/ai/ai-coder:latest

# 启动服务（使用 docker-compose）
ORG_ID=001 FLOW_ID=001 PORT=8001 \
  docker-compose -p ai-flow-001-001 up -d

# 查看日志
docker-compose -p ai-flow-001-001 logs -f

# 停止服务
docker-compose -p ai-flow-001-001 down
```

### 多租户部署

```bash
# 租户 1
ORG_ID=001 FLOW_ID=001 PORT=8001 \
  docker-compose -p ai-flow-001-001 up -d

# 租户 2
ORG_ID=002 FLOW_ID=001 PORT=8002 \
  docker-compose -p ai-flow-002-001 up -d

# 租户 3
ORG_ID=003 FLOW_ID=001 PORT=8003 \
  docker-compose -p ai-flow-003-001 up -d

# 批量部署脚本
for i in {1..5}; do
  org=$(printf "%03d" $i)
  port=$((8000 + i))
  ORG_ID=${org} FLOW_ID=001 PORT=${port} \
    docker-compose -p ai-flow-${org}-001 up -d
done
```

### 开发调试（挂载源码）

```bash
# 修改 docker-compose.yml，添加 volumes 挂载
# 然后启动
ORG_ID=dev FLOW_ID=001 PORT=8000 \
  docker-compose -p ai-flow-dev up -d

# 修改本地代码后，重启服务即可生效
docker-compose -p ai-flow-dev restart
```

### 单独更新某个服务

```bash
# 场景：只修改了 ai-coder 代码

# 1. 重新构建并推送 ai-coder 镜像
docker build -t harbor.blacklake.tech/ai/ai-coder:v1.2.0 -f ai-coder/Dockerfile ai-coder/
docker push harbor.blacklake.tech/ai/ai-coder:v1.2.0

# 2. 拉取新镜像
docker pull harbor.blacklake.tech/ai/ai-coder:v1.2.0

# 3. 只重启 ai-coder 服务（llms 不受影响）
docker-compose -p ai-flow-001-001 up -d --no-deps --build ai-coder
```

### 常用命令

```bash
# 查看所有 compose 实例
docker-compose ls

# 查看特定租户的服务状态
docker-compose -p ai-flow-001-001 ps

# 查看特定租户的日志
docker-compose -p ai-flow-001-001 logs -f

# 查看 ai-coder 服务日志
docker-compose -p ai-flow-001-001 logs -f ai-coder

# 查看 llms 服务日志
docker-compose -p ai-flow-001-001 logs -f llms

# 重启特定租户
docker-compose -p ai-flow-001-001 restart

# 停止特定租户
docker-compose -p ai-flow-001-001 stop

# 删除特定租户
docker-compose -p ai-flow-001-001 down

# 批量停止所有租户
docker ps --filter "name=llms-" --format "{{.Names}}" | cut -d'-' -f2-3 | sort -u | \
  xargs -I {} docker-compose -p ai-flow-{} stop

# 批量删除所有租户
docker ps -a --filter "name=llms-" --format "{{.Names}}" | cut -d'-' -f2-3 | sort -u | \
  xargs -I {} docker-compose -p ai-flow-{} down

# 清理未使用的镜像
docker image prune -f
```

### 方案对比

| 特性 | 方案一：单镜像 | 方案二：多镜像+compose |
|------|--------------|---------------------|
| 部署复杂度 | 简单 | 中等 |
| 启动速度 | 快（1个容器） | 慢（2个容器） |
| 更新灵活性 | 差（需重建整个镜像） | 好（可单独更新服务） |
| 开发调试 | 不便 | 方便（支持 volumes） |
| 容器数量 | 1个/租户 | 2个/租户 |
| 适用场景 | 快速上线 | 长期运维 |

