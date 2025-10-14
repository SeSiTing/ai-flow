#!/bin/bash

# AI Flow Docker Compose 启动脚本
# 用法: ./run-compose.sh [OPTIONS] [ORG_ID] [FLOW_ID] [USE_LLMS]
# 示例: ./run-compose.sh -o 001 -f 002 -p 8080 -l true
# 示例: ./run-compose.sh 001 001 true
# 参数:
#   -o, --org     组织ID
#   -f, --flow    流程ID
#   -p, --port    端口号
#   -n, --name    项目名（可选）
#   -l, --llms    是否使用内部 llms（true/false）

# 默认值
ORG_ID="001"
FLOW_ID="001"
PORT="8000"
PROJECT_NAME=""
USE_LLMS="true"

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--org)
            ORG_ID="$2"
            shift 2
            ;;
        -f|--flow)
            FLOW_ID="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -n|--name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -l|--llms)
            USE_LLMS="$2"
            shift 2
            ;;
        -h|--help)
            echo "AI Flow Docker Compose 启动脚本"
            echo "用法: $0 [OPTIONS] [ORG_ID] [FLOW_ID] [USE_LLMS]"
            echo "参数:"
            echo "  -o, --org     组织ID"
            echo "  -f, --flow    流程ID"
            echo "  -p, --port    端口号"
            echo "  -n, --name    项目名（可选）"
            echo "  -l, --llms    是否使用内部 llms（true/false）"
            echo "  -h, --help    显示帮助信息"
            echo "示例: $0 -o 001 -f 002 -p 8080 -l true"
            echo "示例: $0 001 001 true"
            exit 0
            ;;
        -*)
            echo "❌ 未知参数: $1"
            echo "使用 -h 或 --help 查看帮助信息"
            exit 1
            ;;
        *)
            # 位置参数处理（向后兼容）
            if [[ "$ORG_ID" == "001" ]]; then
                ORG_ID="$1"
            elif [[ "$FLOW_ID" == "001" ]]; then
                FLOW_ID="$1"
            elif [[ "$USE_LLMS" == "true" ]]; then
                USE_LLMS="$1"
            fi
            shift
            ;;
    esac
done

# 设置默认项目名
if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME="ai-flow-${ORG_ID}-${FLOW_ID}"
fi

# 导出环境变量
export ORG_ID FLOW_ID PORT

echo "🚀 启动 AI Flow 服务..."
echo "   组织ID: ${ORG_ID}"
echo "   流程ID: ${FLOW_ID}"
echo "   项目名: ${PROJECT_NAME}"
echo "   使用内部LLMs: ${USE_LLMS}"

# 检查 .env 文件
if [ -f .env ]; then
    echo "📋 加载环境变量文件: .env"
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  未找到 .env 文件，使用默认配置"
fi

# 根据是否使用 llms 决定启动命令
if [ "$USE_LLMS" = "true" ]; then
    echo "📡 启动服务 (含内部 llms)..."
    docker-compose --profile llms -p ${PROJECT_NAME} up -d --pull never
else
    echo "📡 启动服务 (使用外部 llms)..."
    docker-compose -p ${PROJECT_NAME} up -d --pull never
fi

# 检查启动状态
sleep 3
echo "🔍 检查服务状态..."
docker-compose -p ${PROJECT_NAME} ps

echo "✅ 服务启动完成: ${PROJECT_NAME}"
echo ""
echo "📊 管理命令:"
echo "   查看日志: docker-compose -p ${PROJECT_NAME} logs -f"
echo "   查看状态: docker-compose -p ${PROJECT_NAME} ps"
echo "   停止服务: docker-compose -p ${PROJECT_NAME} down"
echo "   重启服务: docker-compose -p ${PROJECT_NAME} restart"
