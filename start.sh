#!/bin/bash

# BiliNote 快速启动脚本
# 用法: ./start.sh [选项]
#   --backend    仅启动后端
#   --frontend   仅启动前端
#   无参数        同时启动前后端

PROJECT_DIR="/workspace/BiliNote"
BACKEND_DIR="$PROJECT_DIR/backend"
FRONTEND_DIR="$PROJECT_DIR/BillNote_frontend"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查端口是否被占用
check_port() {
    local port=$1
    if ss -tlnp 2>/dev/null | grep -q ":$port "; then
        return 0  # 端口被占用
    else
        return 1  # 端口空闲
    fi
}

# 停止已运行的服务
stop_services() {
    print_info "停止现有服务..."
    pkill -f "python main.py" 2>/dev/null
    pkill -f "pnpm dev" 2>/dev/null
    sleep 2
    print_success "服务已停止"
}

# 启动后端
start_backend() {
    print_info "启动后端服务..."
    cd "$BACKEND_DIR"
    
    # 检查端口
    if check_port 8483; then
        print_warning "端口 8483 已被占用"
    fi
    
    # 后台启动后端
    nohup python main.py > /tmp/bilinote_backend.log 2>&1 &
    BACKEND_PID=$!
    echo $BACKEND_PID > /tmp/bilinote_backend.pid
    
    print_info "等待后端启动..."
    
    # 等待最多 15 秒
    for i in {1..15}; do
        sleep 1
        if check_port 8483; then
            print_success "后端启动成功 (PID: $BACKEND_PID)"
            print_info "后端地址: http://127.0.0.1:8483"
            print_info "API 文档: http://127.0.0.1:8483/docs"
            return 0
        fi
    done
    
    print_error "后端启动失败，请查看日志: /tmp/bilinote_backend.log"
}

# 启动前端
start_frontend() {
    print_info "启动前端服务..."
    cd "$FRONTEND_DIR"
    
    # 检查端口
    if check_port 3015; then
        print_warning "端口 3015 已被占用"
    fi
    
    # 后台启动前端
    nohup pnpm dev > /tmp/bilinote_frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo $FRONTEND_PID > /tmp/bilinote_frontend.pid
    
    print_info "等待前端启动..."
    
    # 等待最多 15 秒
    for i in {1..15}; do
        sleep 1
        if check_port 3015; then
            print_success "前端启动成功 (PID: $FRONTEND_PID)"
            print_info "前端地址: http://localhost:3015"
            return 0
        fi
    done
    
    print_error "前端启动失败，请查看日志: /tmp/bilinote_frontend.log"
}

# 显示服务状态
show_status() {
    echo ""
    echo "================================"
    echo "       BiliNote 服务状态"
    echo "================================"
    
    if check_port 8483; then
        echo -e "后端: ${GREEN}运行中${NC} (http://127.0.0.1:8483)"
    else
        echo -e "后端: ${RED}未运行${NC}"
    fi
    
    if check_port 3015; then
        echo -e "前端: ${GREEN}运行中${NC} (http://localhost:3015)"
    else
        echo -e "前端: ${RED}未运行${NC}"
    fi
    
    echo "================================"
    echo ""
    echo "日志文件:"
    echo "  后端: /tmp/bilinote_backend.log"
    echo "  前端: /tmp/bilinote_frontend.log"
    echo ""
    echo "停止服务: ./stop.sh"
    echo ""
}

# 主函数
main() {
    cd "$PROJECT_DIR"
    
    case "$1" in
        --backend)
            stop_services
            start_backend
            ;;
        --frontend)
            stop_services
            start_frontend
            ;;
        --status)
            show_status
            ;;
        *)
            stop_services
            start_backend
            start_frontend
            show_status
            ;;
    esac
}

main "$@"
