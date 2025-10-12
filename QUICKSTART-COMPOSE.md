# Docker Compose 快速开始

## 📦 文件结构

```
ai-flow/
├── docker-compose.yml          # 服务编排配置
├── llms/
│   ├── Dockerfile             # llms 服务镜像
│   └── .dockerignore
├── ai-coder/
│   ├── Dockerfile             # ai-coder 服务镜像
│   └── .dockerignore
└── .env                       # 环境变量配置
```

## 🚀 快速开始

### 1. 配置环境变量

```bash
# 创建 .env 文件
cat > .env << EOF
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxx
ANTHROPIC_API_KEY=custom
EOF
```

### 2. 本地构建测试

```bash
# 构建镜像（首次需要）
docker-compose build

# 启动单个租户
ORG_ID=001 FLOW_ID=001 PORT=8001 docker-compose -p ai-flow-001-001 up -d

# 查看日志
docker-compose -p ai-flow-001-001 logs -f

# 测试服务
curl http://localhost:8001/status
```

### 3. 生产环境部署

```bash
# 登录 Harbor
docker login harbor.blacklake.tech

# 拉取镜像
docker pull harbor.blacklake.tech/ai/llms:latest
docker pull harbor.blacklake.tech/ai/ai-coder:latest

# 启动租户
ORG_ID=001 FLOW_ID=001 PORT=8001 docker-compose -p ai-flow-001-001 up -d
```

## 📊 多租户部署示例

```bash
# 批量启动 5 个租户
for i in {1..5}; do
  org=$(printf "%03d" $i)
  port=$((8000 + i))
  echo "启动租户 ${org}，端口 ${port}"
  ORG_ID=${org} FLOW_ID=001 PORT=${port} \
    docker-compose -p ai-flow-${org}-001 up -d
done

# 查看所有租户
docker ps --filter "name=ai-coder-" --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"
```

## 🔧 管理命令

```bash
# 查看租户状态
docker-compose -p ai-flow-001-001 ps

# 查看日志
docker-compose -p ai-flow-001-001 logs -f

# 重启租户
docker-compose -p ai-flow-001-001 restart

# 停止租户
docker-compose -p ai-flow-001-001 stop

# 删除租户
docker-compose -p ai-flow-001-001 down
```

## 🛠️ 开发调试

### 挂载源码进行开发

修改 `docker-compose.yml`，在对应服务下添加 volumes：

```yaml
services:
  llms:
    volumes:
      - ./llms/src:/app/llms/src
  
  ai-coder:
    volumes:
      - ./ai-coder/src:/app/ai-coder/src
```

然后启动：

```bash
ORG_ID=dev FLOW_ID=001 PORT=8000 docker-compose -p ai-flow-dev up -d

# 修改代码后重启服务
docker-compose -p ai-flow-dev restart
```

## 🔄 更新服务

### 只更新 ai-coder 服务

```bash
# 1. 构建新镜像
docker build -t harbor.blacklake.tech/ai/ai-coder:v1.2.0 -f ai-coder/Dockerfile ai-coder/

# 2. 推送镜像
docker push harbor.blacklake.tech/ai/ai-coder:v1.2.0

# 3. 更新运行中的服务
docker-compose -p ai-flow-001-001 pull ai-coder
docker-compose -p ai-flow-001-001 up -d ai-coder
```

### 只更新 llms 服务

```bash
# 1. 构建新镜像
docker build -t harbor.blacklake.tech/ai/llms:v1.2.0 -f llms/Dockerfile llms/

# 2. 推送镜像
docker push harbor.blacklake.tech/ai/llms:v1.2.0

# 3. 更新运行中的服务
docker-compose -p ai-flow-001-001 pull llms
docker-compose -p ai-flow-001-001 up -d llms
```

## 📈 优势说明

✅ **独立更新**：可以只更新 llms 或 ai-coder，无需重建整个镜像
✅ **开发友好**：支持 volumes 挂载源码，修改代码即时生效
✅ **服务解耦**：llms 和 ai-coder 完全独立，便于维护
✅ **灵活扩展**：未来可以轻松添加 mcp 等新服务
✅ **共享优化**：未来可以将 llms 改为共享服务，节省资源

## 🔍 故障排查

```bash
# 查看容器状态
docker-compose -p ai-flow-001-001 ps

# 查看完整日志
docker-compose -p ai-flow-001-001 logs

# 查看 llms 服务日志
docker-compose -p ai-flow-001-001 logs llms

# 查看 ai-coder 服务日志
docker-compose -p ai-flow-001-001 logs ai-coder

# 重启服务
docker-compose -p ai-flow-001-001 restart

# 完全重建
docker-compose -p ai-flow-001-001 down
ORG_ID=001 FLOW_ID=001 PORT=8001 docker-compose -p ai-flow-001-001 up -d --build
```

## 📝 注意事项

1. **环境变量**：`ORG_ID`、`FLOW_ID`、`PORT` 必须在启动时传递
2. **端口冲突**：确保每个租户使用不同的 PORT
3. **项目名**：使用 `-p` 参数隔离不同租户的 compose 项目
4. **网络**：llms 和 ai-coder 通过 Docker 网络 `ai-flow-network` 通信
5. **健康检查**：ai-coder 会等待 llms 健康检查通过后再启动

