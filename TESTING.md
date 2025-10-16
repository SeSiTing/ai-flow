# 测试验证指南

## 🧪 服务验证

### 基础服务检查

**使用 curl:**
```bash
curl http://localhost:8000/status
```

**使用 httpie:**
```bash
http GET http://localhost:8000/status
```

### API 接口测试

**使用 curl:**
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "你好"}'
```

**使用 httpie:**
```bash
http POST http://localhost:8000/chat message="你好"
```

## 🐳 Docker 容器管理

### 启动容器
```bash
# 使用启动脚本（推荐）
./run-compose.sh -o 001 -f 001

# 或手动启动
docker run -d \
  --name ai-flow \
  -p 8000:8000 \
  --env-file .env \
  sesiting/ai-flow:latest
```

### 关闭容器
```bash
# 使用启动脚本停止
docker-compose -p ai-flow-001-001 down

# 或手动停止容器
docker stop ai-flow

# 停止并删除容器
docker stop ai-flow && docker rm ai-flow
```

### 查看容器状态
```bash
# 查看运行中的容器
docker ps

# 查看容器日志（使用启动脚本）
docker-compose -p ai-flow-001-001 logs -f

# 查看容器日志（手动启动）
docker logs -f ai-flow
```

## 🔧 故障排除

### 端口冲突检查
```bash
# 检查端口占用
lsof -i :8000

# 使用不同端口启动
./run-compose.sh -o 001 -f 001 -p 8001
```

### 服务启动问题
```bash
# 查看容器日志
docker logs -f ai-flow

# 本地开发查看日志
cd llms && npm start
cd ai-coder && uv run api
```

### Claude Code 安装
```bash
# 本地安装 Claude Code
npm install -g @anthropic-ai/claude-code
```

## 📊 性能测试

### 响应时间测试

**使用 curl:**
```bash
time curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello"}'
```

**使用 httpie:**
```bash
time http POST http://localhost:8000/chat message="Hello"
```

### 并发测试
```bash
# 需要先创建 test.json: {"message": "Hello"}
ab -n 100 -c 10 -p test.json -T application/json http://localhost:8000/chat
```

## 🎯 常用测试场景

### 远程测试
使用 `http://10.83.20.125:8000/chat`（替换为实际服务器 IP）

#### 1. 基础问候
```bash
http POST http://10.83.20.125:8000/chat message="你好"
```

#### 2. 生成代码
```bash
http POST http://10.83.20.125:8000/chat message="生成一个 hello.py"
```

#### 3. 修改代码
```bash
http POST http://10.83.20.125:8000/chat message="修改 hello.py，添加输入姓名功能"
```

### curl 替代命令

```bash
# 基础问候
curl -X POST http://10.83.20.125:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "你好"}'

# 生成代码
curl -X POST http://10.83.20.125:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "生成一个 hello.py"}'

# 修改代码
curl -X POST http://10.83.20.125:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "修改 hello.py，添加输入姓名功能"}'
```

