#!/bin/bash

echo "🚀 启动 AI Flow 服务..."

# 加载环境变量（支持本地开发）
if [ -f .env ]; then
    echo "📋 加载环境变量..."
    export $(cat .env | grep -v '^#' | xargs)
fi

# 显示关键环境变量（调试用）
echo "🔧 环境变量检查:"
echo "  ANTHROPIC_BASE_URL: ${ANTHROPIC_BASE_URL:-未设置}"
echo "  ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:-未设置}"
echo "  PROJECT_ROOT: ${PROJECT_ROOT:-未设置}"
echo "  ORG_ID: ${ORG_ID:-未设置}"
echo "  FLOW_ID: ${FLOW_ID:-未设置}"

# 启动 llms 服务（后台）
echo "📡 启动 LLMs 服务 (端口: 3000)..."
cd llms
npm start &
LLMS_PID=$!

# 等待 llms 服务启动
echo "⏳ 等待 LLMs 服务启动..."
sleep 5

# 检查 llms 服务是否启动成功
if ! curl -f http://localhost:${LLMS_PORT:-3000}/health > /dev/null 2>&1; then
    echo "❌ LLMs 服务启动失败"
    exit 1
fi
echo "✅ LLMs 服务启动成功"

# 启动 ai-coder 服务
echo "🤖 启动 AI Coder 服务 (端口: ${AI_CODER_PORT:-8000})..."
cd ../ai-coder
uv run api &
AI_CODER_PID=$!

# 等待 ai-coder 服务启动
sleep 3

# 检查 ai-coder 服务是否启动成功
if ! curl -f http://localhost:${AI_CODER_PORT:-8000}/status > /dev/null 2>&1; then
    echo "❌ AI Coder 服务启动失败"
    exit 1
fi
echo "✅ AI Coder 服务启动成功"

echo "🎉 所有服务启动完成！"
echo "📡 LLMs API: http://localhost:${LLMS_PORT:-3000}"
echo "🤖 AI Coder API: http://localhost:${AI_CODER_PORT:-8000}"
echo "📚 API 文档: http://localhost:${AI_CODER_PORT:-8000}/docs"

# 等待进程
wait $LLMS_PID $AI_CODER_PID
