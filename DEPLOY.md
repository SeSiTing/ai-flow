# 部署文档

## 构建推送

```bash
# 登录
echo "Gitlabci123" | docker login --username gitlabci --password-stdin harbor.blacklake.tech

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
echo "Gitlabci123" | docker login --username gitlabci --password-stdin harbor.blacklake.tech
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

## 常用命令

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

