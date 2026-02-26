@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: BiliNote Windows 启动脚本
:: 支持自动检测并激活 Conda 虚拟环境
:: 用法: 双击运行或在 cmd 中执行 start.bat

:: 设置项目目录
set "PROJECT_DIR=%~dp0"
set "BACKEND_DIR=%PROJECT_DIR%backend"
set "FRONTEND_DIR=%PROJECT_DIR%BillNote_frontend"

:: 设置 Conda 环境名称（可根据需要修改）
set "CONDA_ENV_NAME=bilinote"

:: 颜色设置（Windows 10+ 支持）
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

echo.
echo ================================================
echo         BiliNote Windows 启动脚本
echo ================================================
echo.

:: 检测 Conda 是否可用
echo [检查] Conda 环境...
where conda >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%[提示] 未检测到 Conda，将使用系统 Python%NC%
    set "USE_CONDA=0"
) else (
    echo %GREEN%[OK] 检测到 Conda%NC%
    set "USE_CONDA=1"
)

:: 如果使用 Conda，检查虚拟环境
if "%USE_CONDA%"=="1" (
    :: 初始化 Conda（确保可以在脚本中使用）
    call conda activate base >nul 2>&1
    
    :: 检查 bilinote 环境是否存在
    conda env list | findstr /C:"%CONDA_ENV_NAME%" >nul
    if errorlevel 1 (
        echo %YELLOW%[警告] Conda 环境 '%CONDA_ENV_NAME%' 不存在%NC%
        echo.
        echo 请先创建环境：
        echo   conda create -n %CONDA_ENV_NAME% python=3.11 -y
        echo   conda activate %CONDA_ENV_NAME%
        echo   cd backend
        echo   pip install -r requirements.txt
        echo.
        echo 或使用普通 Python 环境继续...
        set "USE_CONDA=0"
    ) else (
        echo %GREEN%[OK] Conda 环境 '%CONDA_ENV_NAME%' 已存在%NC%
    )
)

:: 检查 Python
echo [检查] Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo %RED%[错误] Python 未安装，请先安装 Python 3.10+%NC%
    if "%USE_CONDA%"=="1" (
        echo 或创建 Conda 环境: conda create -n %CONDA_ENV_NAME% python=3.11 -y
    ) else (
        echo 下载地址: https://www.python.org/downloads/
    )
    pause
    exit /b 1
)

:: 显示 Python 版本
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VER=%%i
echo %GREEN%[OK] Python %PYTHON_VER% 已就绪%NC%

:: 检查 Node.js
echo [检查] Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo %RED%[错误] Node.js 未安装，请先安装 Node.js%NC%
    echo 下载地址: https://nodejs.org/
    pause
    exit /b 1
)
echo %GREEN%[OK] Node.js 已安装%NC%

:: 检查 pnpm
echo [检查] pnpm...
pnpm --version >nul 2>&1
if errorlevel 1 (
    echo %YELLOW%[警告] pnpm 未安装，正在安装...%NC%
    npm install -g pnpm
    if errorlevel 1 (
        echo %RED%[错误] pnpm 安装失败%NC%
        pause
        exit /b 1
    )
)
echo %GREEN%[OK] pnpm 已安装%NC%

:: 检查 ffmpeg
echo [检查] ffmpeg...
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo %RED%[错误] ffmpeg 未安装或未添加到 PATH%NC%
    echo 下载地址: https://www.gyan.dev/ffmpeg/builds/
    pause
    exit /b 1
)
echo %GREEN%[OK] ffmpeg 已安装%NC%

:: 检查 .env 文件
if not exist "%PROJECT_DIR%.env" (
    echo %YELLOW%[提示] .env 文件不存在，正在从 .env.example 复制...%NC%
    copy "%PROJECT_DIR%.env.example" "%PROJECT_DIR%.env" >nul
    echo %GREEN%[OK] .env 文件已创建%NC%
)

echo.
echo ================================================
echo              启动服务
echo ================================================
echo.

:: 停止已有服务
echo [停止] 正在停止已有服务...
taskkill /F /FI "WINDOWTITLE eq BiliNote-Backend*" >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq BiliNote-Frontend*" >nul 2>&1
timeout /t 2 >nul

:: 启动后端
echo [启动] 正在启动后端服务...
if "%USE_CONDA%"=="1" (
    :: 使用 Conda 环境启动后端
    start "BiliNote-Backend" cmd /k "call conda activate %CONDA_ENV_NAME% && cd /d %BACKEND_DIR% && python main.py"
) else (
    :: 使用系统 Python 启动后端
    start "BiliNote-Backend" cmd /k "cd /d %BACKEND_DIR% && python main.py"
)
echo %GREEN%[OK] 后端服务已启动%NC%
echo       地址: http://localhost:8483
echo       文档: http://localhost:8483/docs

:: 等待后端启动
echo [等待] 等待后端初始化...
timeout /t 5 >nul

:: 启动前端
echo [启动] 正在启动前端服务...
start "BiliNote-Frontend" cmd /k "cd /d %FRONTEND_DIR% && pnpm dev"
echo %GREEN%[OK] 前端服务已启动%NC%
echo       地址: http://localhost:3015

echo.
echo ================================================
echo              启动完成
echo ================================================
echo.
if "%USE_CONDA%"=="1" (
    echo %BLUE%Conda 环境: %CONDA_ENV_NAME%%NC%
)
echo %GREEN%后端: http://localhost:8483%NC%
echo %GREEN%前端: http://localhost:3015%NC%
echo.
echo 提示: 
echo   - 后端和前端分别在独立的命令窗口中运行
echo   - 关闭对应的窗口即可停止服务
echo   - 或运行 stop.bat 停止所有服务
echo.
echo 按任意键退出此窗口（服务将继续运行）...
pause >nul
