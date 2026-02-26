#!/bin/bash

# BiliNote 停止脚本

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info "停止 BiliNote 服务..."

# 停止后端
if [ -f /tmp/bilinote_backend.pid ]; then
    PID=$(cat /tmp/bilinote_backend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null
        print_success "后端已停止 (PID: $PID)"
    fi
    rm -f /tmp/bilinote_backend.pid
fi

# 停止前端
if [ -f /tmp/bilinote_frontend.pid ]; then
    PID=$(cat /tmp/bilinote_frontend.pid)
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null
        print_success "前端已停止 (PID: $PID)"
    fi
    rm -f /tmp/bilinote_frontend.pid
fi

# 强制清理
pkill -f "python main.py" 2>/dev/null
pkill -f "pnpm dev" 2>/dev/null

print_success "所有服务已停止"
