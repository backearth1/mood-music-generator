#!/bin/bash

# 启动脚本

echo "🎵 心情音乐生成器启动中..."

# 检查 .env 文件
if [ ! -f .env ]; then
    echo "⚠️  警告：未找到 .env 文件"
    echo "请复制 .env.example 为 .env 并配置你的 API Key"
    echo "运行: cp .env.example .env"
    exit 1
fi

# 检查依赖
if ! python3 -c "import fastapi" 2>/dev/null; then
    echo "📦 正在安装依赖..."
    pip install -r requirements.txt
fi

# 创建临时目录
mkdir -p temp_sessions

# 启动服务
echo "✅ 启动 FastAPI 服务..."
python3 main.py
