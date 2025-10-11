FROM python:3.13-slim

# 安装 Node.js 20 和必要工具
RUN apt-get update && apt-get install -y \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 安装公共依赖（优先安装，最大化缓存利用）
# 自动检测并切换 npm 镜像源
RUN npm config set registry https://registry.npmjs.org/ && \
    timeout 30 npm install -g @anthropic-ai/claude-code || \
    (echo "⚠️ 官方源超时，切换到阿里源..." && \
     npm config set registry https://registry.npmmirror.com/ && \
     npm install -g @anthropic-ai/claude-code)

# 安装 uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

WORKDIR /app

# 复制 llms 项目
COPY llms/ ./llms/
WORKDIR /app/llms
RUN npm install && npm run build && npm cache clean --force

# 复制 ai-coder 项目
WORKDIR /app
COPY ai-coder/ ./ai-coder/
WORKDIR /app/ai-coder
RUN uv sync

# 创建启动脚本
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# 设置默认工作目录
WORKDIR /app

CMD ["/app/start.sh"]
