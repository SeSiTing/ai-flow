#!/bin/bash

# AI Flow Docker Compose 管理脚本
# 用法: ./run-compose.sh [COMMAND] [OPTIONS] [ORG_ID] [FLOW_ID] [USE_LLMS]
# 示例: ./run-compose.sh up -o 001 -f 002 -p 8080          # 启动服务（使用外部 llms）
# 示例: ./run-compose.sh up -o 001 -f 002 -l true         # 启动服务（使用内部 llms）
# 示例: ./run-compose.sh down -o 001 -f 002               # 关闭服务
# 示例: ./run-compose.sh build -o 001 -f 002              # 构建镜像
# 示例: ./run-compose.sh restart -o 001 -f 002            # 重启服务
# 命令:
#   up        启动服务（默认）
#   down      关闭服务
#   build     构建镜像
#   restart   重启服务
# 参数:
#   -o, --org     组织ID
#   -f, --flow    流程ID
#   -p, --port    端口号
#   -n, --name    项目名（可选）
#   -l, --llms    是否使用内部 llms（true/false）

# 默认值
PORT="8000"
PROJECT_NAME=""
USE_LLMS="false"
ENV=""
COMMAND="up"
ORG_ID="default"
FLOW_ID="default"

# 解析命令
if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
    COMMAND="$1"
    shift
fi

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
        -e|--env)
            ENV="$2"
            shift 2
            ;;
        -h|--help)
            echo "AI Flow Docker Compose 管理脚本"
            echo "用法: $0 [COMMAND] [OPTIONS]"
            echo "命令:"
            echo "  up        启动服务（默认）"
            echo "  down      关闭服务"
            echo "  build     构建镜像"
            echo "  restart   重启服务"
            echo "参数:"
            echo "  -o, --org     组织ID（默认: default）"
            echo "  -f, --flow    流程ID（默认: default）"
            echo "  -p, --port    端口号（默认: 8000）"
            echo "  -n, --name    项目名（可选）"
            echo "  -l, --llms    是否使用内部 llms（默认: false）"
            echo "  -e, --env     环境配置（dev/prod）"
            echo "  -h, --help    显示帮助信息"
            echo "示例:"
            echo "  $0 up                               # 使用默认值启动服务"
            echo "  $0 restart                          # 使用默认值重启服务"
            echo "  $0 up -o 001 -f 002 -p 8080        # 启动服务（使用外部 llms）"
            echo "  $0 up -o 001 -f 002 -l true        # 启动服务（使用内部 llms）"
            echo "  $0 down -o 001 -f 002              # 关闭服务"
            echo "  $0 build -o 001 -f 002             # 构建镜像"
            exit 0
            ;;
        -*)
            echo "❌ 未知参数: $1"
            echo "使用 -h 或 --help 查看帮助信息"
            exit 1
            ;;
        *)
            # 位置参数处理（向后兼容）
            if [[ -z "$ORG_ID" ]]; then
                ORG_ID="$1"
            elif [[ -z "$FLOW_ID" ]]; then
                FLOW_ID="$1"
            elif [[ "$USE_LLMS" == "false" ]]; then
                USE_LLMS="$1"
            elif [[ -z "$ENV" ]]; then
                ENV="$1"
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
[[ -n "$ORG_ID" ]] && export ORG_ID
[[ -n "$FLOW_ID" ]] && export FLOW_ID
export PORT

# 确定配置文件
if [[ "$ENV" == "prod" ]]; then
    COMPOSE_FILE="docker-compose.prod.yml"
elif [[ "$ENV" == "dev" ]]; then
    COMPOSE_FILE="docker-compose.dev.yml"
else
    COMPOSE_FILE="docker-compose.yml"
fi

# 检查 .env 文件
if [ -f .env ]; then
    echo "📋 加载环境变量文件: .env"
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  未找到 .env 文件，使用默认配置"
fi

# 执行命令
case "$COMMAND" in
    "up")
        echo "🚀 启动 AI Flow 服务..."
        echo "   组织ID: ${ORG_ID}"
        echo "   流程ID: ${FLOW_ID}"
        echo "   项目名: ${PROJECT_NAME}"
        echo "   环境配置: ${ENV} (${COMPOSE_FILE})"
        echo "   使用内部LLMs: ${USE_LLMS}"
        
        # 根据是否使用 llms 决定启动命令
        if [ "$USE_LLMS" = "true" ]; then
            echo "📡 启动服务 (含内部 llms)..."
            echo "🔧 执行命令: docker compose -f ${COMPOSE_FILE} --profile llms -p ${PROJECT_NAME} up -d --pull never"
            docker compose -f ${COMPOSE_FILE} --profile llms -p ${PROJECT_NAME} up -d --pull never
        else
            echo "📡 启动服务 (使用外部 llms)..."
            echo "🔧 执行命令: docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} up -d --pull never"
            docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} up -d --pull never
        fi
        
        # 检查启动状态
        sleep 3
        echo "🔍 检查服务状态..."
        docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} ps
        echo "✅ 服务启动完成: ${PROJECT_NAME}"
        ;;
        
    "down")
        echo "🛑 关闭 AI Flow 服务..."
        echo "   项目名: ${PROJECT_NAME}"
        echo "   环境配置: ${ENV} (${COMPOSE_FILE})"
        
        echo "🔧 执行命令: docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} down"
        docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} down
        echo "✅ 服务已关闭: ${PROJECT_NAME}"
        ;;
        
    "build")
        echo "🔨 构建 AI Flow 镜像..."
        echo "   项目名: ${PROJECT_NAME}"
        echo "   环境配置: ${ENV} (${COMPOSE_FILE})"
        
        if [ "$USE_LLMS" = "true" ]; then
            echo "📦 构建镜像 (含内部 llms)..."
            echo "🔧 执行命令: docker compose -f ${COMPOSE_FILE} --profile llms -p ${PROJECT_NAME} build"
            docker compose -f ${COMPOSE_FILE} --profile llms -p ${PROJECT_NAME} build
        else
            echo "📦 构建镜像 (使用外部 llms)..."
            echo "🔧 执行命令: docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} build"
            docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} build
        fi
        echo "✅ 镜像构建完成: ${PROJECT_NAME}"
        ;;
        
    "restart")
        echo "🔄 重启 AI Flow 服务..."
        echo "   项目名: ${PROJECT_NAME}"
        echo "   环境配置: ${ENV} (${COMPOSE_FILE})"
        echo "   使用内部LLMs: ${USE_LLMS}"
        
        # 先停止并删除容器
        echo "🛑 停止服务..."
        echo "🔧 执行命令: docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} down"
        docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} down
        
        # 重新构建并启动服务（确保代码更新生效）
        echo "🔨 重新构建镜像..."
        if [ "$USE_LLMS" = "true" ]; then
            echo "🔧 执行命令: docker compose -f ${COMPOSE_FILE} --profile llms -p ${PROJECT_NAME} build"
            docker compose -f ${COMPOSE_FILE} --profile llms -p ${PROJECT_NAME} build
            echo "🚀 重新启动服务 (含内部 llms)..."
            echo "🔧 执行命令: docker compose -f ${COMPOSE_FILE} --profile llms -p ${PROJECT_NAME} up -d --force-recreate"
            docker compose -f ${COMPOSE_FILE} --profile llms -p ${PROJECT_NAME} up -d --force-recreate
        else
            echo "🔧 执行命令: docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} build"
            docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} build
            echo "🚀 重新启动服务 (使用外部 llms)..."
            echo "🔧 执行命令: docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} up -d --force-recreate"
            docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} up -d --force-recreate
        fi
        
        # 检查重启状态
        sleep 3
        echo "🔍 检查服务状态..."
        docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} ps
        echo "✅ 服务重启完成: ${PROJECT_NAME}"
        ;;
        
    *)
        echo "❌ 未知命令: $COMMAND"
        echo "支持的命令: up, down, build, restart"
        echo "使用 -h 或 --help 查看帮助信息"
        exit 1
        ;;
esac

echo ""
echo "📊 管理命令:"
echo "   查看日志: docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} logs -f"
echo "   查看状态: docker compose -f ${COMPOSE_FILE} -p ${PROJECT_NAME} ps"
echo "   停止服务: $0 down -o ${ORG_ID} -f ${FLOW_ID}"
echo "   重启服务: $0 restart -o ${ORG_ID} -f ${FLOW_ID}"
echo "   构建镜像: $0 build -o ${ORG_ID} -f ${FLOW_ID}"
