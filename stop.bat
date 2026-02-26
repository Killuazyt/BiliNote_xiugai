@echo off
chcp 65001 >nul

:: BiliNote Windows 停止脚本

echo.
echo ================================================
echo         BiliNote Windows 停止脚本
echo ================================================
echo.

echo [停止] 正在停止后端服务...
taskkill /F /FI "WINDOWTITLE eq BiliNote-Backend*" >nul 2>&1
if errorlevel 1 (
    echo [提示] 后端服务未运行
) else (
    echo [OK] 后端服务已停止
)

echo [停止] 正在停止前端服务...
taskkill /F /FI "WINDOWTITLE eq BiliNote-Frontend*" >nul 2>&1
if errorlevel 1 (
    echo [提示] 前端服务未运行
) else (
    echo [OK] 前端服务已停止
)

:: 额外清理可能残留的进程
taskkill /F /IM "python.exe" /FI "WINDOWTITLE eq BiliNote*" >nul 2>&1
taskkill /F /IM "node.exe" /FI "WINDOWTITLE eq BiliNote*" >nul 2>&1

echo.
echo ================================================
echo              所有服务已停止
echo ================================================
echo.

timeout /t 3
