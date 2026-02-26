# BiliNote Windows 安装指南

## 目录

1. [环境要求](#环境要求)
2. [安装步骤（推荐 Conda 方式）](#安装步骤推荐-conda-方式)
3. [安装步骤（普通方式）](#安装步骤普通方式)
4. [CUDA 加速配置](#cuda-加速配置)
5. [快速启动](#快速启动)
6. [常见问题](#常见问题)

---

## 环境要求

| 软件 | 版本要求 | 下载地址 |
|------|----------|----------|
| **Miniconda** | 最新版 (推荐) | https://docs.conda.io/en/latest/miniconda.html |
| Python | 3.10 - 3.11 | 通过 Conda 安装 |
| Node.js | 18.x - 22.x | https://nodejs.org/ |
| pnpm | 最新版 | 安装 Node.js 后运行 `npm install -g pnpm` |
| ffmpeg | 最新版 | https://www.gyan.dev/ffmpeg/builds/ |
| Git | 最新版 | https://git-scm.com/download/win |
| CUDA Toolkit | 12.x (可选，GPU加速) | https://developer.nvidia.com/cuda-downloads |

> **推荐**: 使用 Miniconda 管理 Python 环境，可以避免依赖冲突，更容易配置 CUDA。

---

## 安装步骤（推荐 Conda 方式）

### 步骤 1: 安装 Miniconda

1. 下载 Miniconda: https://docs.conda.io/en/latest/miniconda.html
   - 选择 Windows 64-bit 版本
   - 下载后运行安装程序

2. 安装时的选项：
   - **推荐勾选** `Add Miniconda3 to my PATH environment variable`
   - 或者在安装后使用 "Anaconda Prompt" 来运行命令

3. 验证安装（打开新的命令提示符）：
   ```cmd
   conda --version
   ```

### 步骤 2: 安装 Node.js 和 pnpm

1. 下载 Node.js LTS 版本: https://nodejs.org/
2. 安装完成后验证：
   ```cmd
   node --version
   npm --version
   ```
3. 安装 pnpm：
   ```cmd
   npm install -g pnpm
   pnpm --version
   ```

### 步骤 3: 安装 ffmpeg

1. 下载 ffmpeg: https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip
2. 解压到 `C:\ffmpeg`
3. 添加到系统环境变量：
   - 右键"此电脑" → 属性 → 高级系统设置 → 环境变量
   - 在"系统变量"中找到 `Path`，点击编辑
   - 添加 `C:\ffmpeg\bin`
4. 验证安装：
   ```cmd
   ffmpeg -version
   ```

### 步骤 4: 克隆项目

```cmd
# 进入你想安装的目录
cd C:\

# 克隆项目
git clone https://github.com/你的用户名/BiliNote.git
cd BiliNote

# 复制环境配置文件
copy .env.example .env
```

### 步骤 5: 创建 Conda 虚拟环境

**方式一：手动创建（推荐新手）**

```cmd
# 创建名为 bilinote 的虚拟环境，Python 版本 3.11
conda create -n bilinote python=3.11 -y

# 激活虚拟环境
conda activate bilinote

# 验证环境
python --version
which python
```

**方式二：使用配置文件快速创建（推荐）**

项目提供了 `environment.yml` 配置文件，可以一键创建完整的 Conda 环境：

```cmd
# 在项目根目录执行，将自动创建环境并安装所有依赖
conda env create -f environment.yml

# 激活环境
conda activate bilinote
```

> **注意**: 使用 `environment.yml` 创建环境会自动安装 PyTorch CUDA 版本和后端依赖，更加方便快捷。

### 步骤 6: 安装后端依赖

> 如果使用 `environment.yml` 创建环境，此步骤可跳过，依赖已自动安装。

```cmd
# 确保已激活 bilinote 环境
conda activate bilinote

# 进入后端目录
cd backend

# 安装依赖（使用国内镜像加速）
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

# 返回项目根目录
cd ..
```

### 步骤 7: 安装前端依赖

```cmd
cd BillNote_frontend
pnpm install
cd ..
```

### 步骤 8: 保存环境配置（可选）

为了方便以后恢复环境，可以导出 conda 环境配置：

```cmd
# 导出环境配置
conda env export > environment.yml

# 以后可以用以下命令恢复环境
# conda env create -f environment.yml
```

---

## 安装步骤（普通方式）

如果不使用 Conda，可以按以下步骤安装：

### 步骤 1: 安装 Python

1. 下载 Python 3.11: https://www.python.org/downloads/release/python-3110/
2. 运行安装程序，**务必勾选** `Add Python to PATH`
3. 验证安装：
   ```cmd
   python --version
   pip --version
   ```

### 步骤 2 ~ 步骤 6

参考上方 Conda 方式的对应步骤，但无需创建虚拟环境。

---

## CUDA 加速配置

### 支持的 GPU

所有支持 CUDA 的 NVIDIA 显卡均可使用，包括：

| GPU 系列 | 型号示例 |
|----------|----------|
| RTX 50 系列 | RTX 5090, 5080, 5070, 5060 |
| RTX 40 系列 | RTX 4090, 4080, 4070, 4060, 4050 |
| RTX 30 系列 | RTX 3090, 3080, 3070, 3060, 3050 |
| Tesla/数据中心 | T4, V100, A100, A10, H100 |

### 安装 CUDA Toolkit（可选，推荐有 GPU 的用户）

1. 检查显卡是否支持 CUDA：
   - 打开"任务管理器" → "性能" → "GPU"
   - 如果显示 NVIDIA 显卡，则支持 CUDA

2. 下载 CUDA Toolkit 12.x: https://developer.nvidia.com/cuda-downloads
   - 选择：Windows → x86_64 → 版本 → exe (local)
   - 安装时选择"精简"模式

3. 验证安装：
   ```cmd
   nvcc --version
   nvidia-smi
   ```

### 在 Conda 环境中安装 PyTorch CUDA 版本

**推荐方式：使用 Conda 安装 PyTorch**

```cmd
# 激活虚拟环境
conda activate bilinote

# 安装 PyTorch with CUDA 12.x
conda install pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia -y

# 或者使用 pip 安装
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
```

### 验证 CUDA 配置

```cmd
# 激活环境
conda activate bilinote

# 验证 CUDA
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}'); print(f'GPU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else \"N/A\"}')"
```

输出示例：
```
CUDA available: True
GPU: NVIDIA GeForce RTX 4060
```

### 模型大小选择

根据显卡显存选择合适的模型：

| 模型 | 显存需求 | 推荐显卡 |
|------|----------|----------|
| base | ~1GB | 任意 GPU |
| small | ~2GB | 4GB+ 显存 |
| medium | ~5GB | RTX 4060/5060 (8GB) |
| large-v3 | ~10GB | RTX 4070/5070+ (12GB+) |

修改 `.env` 文件中的配置：
```bash
WHISPER_MODEL_SIZE=medium  # 根据你的显卡选择
```

---

## 快速启动

### 使用启动脚本（自动激活 Conda 环境）

双击运行项目根目录下的 `start.bat` 文件，或在命令提示符中执行：

```cmd
start.bat
```

启动脚本会自动：
1. 检测并激活 `bilinote` conda 环境
2. 启动后端服务
3. 启动前端服务

### 手动启动（使用 Conda）

**启动后端**（打开第一个命令提示符）：
```cmd
# 激活虚拟环境
conda activate bilinote

# 进入后端目录并启动
cd C:\BiliNote\backend
python main.py
```

**启动前端**（打开第二个命令提示符）：
```cmd
cd C:\BiliNote\BillNote_frontend
pnpm dev
```

### 访问地址

- **前端界面**: http://localhost:3015
- **后端 API 文档**: http://localhost:8483/docs

---

## 常见问题

### Q1: Conda 命令找不到

如果安装时没有勾选添加 PATH，需要：
- 使用开始菜单中的 "Anaconda Prompt"
- 或手动添加环境变量：
  - `C:\Users\你的用户名\miniconda3`
  - `C:\Users\你的用户名\miniconda3\Scripts`

### Q2: Conda 环境激活失败

```cmd
# 初始化 conda 到 cmd
conda init cmd.exe

# 然后重新打开命令提示符
```

### Q3: pip 安装依赖速度慢

使用国内镜像源：
```cmd
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
```

或配置永久镜像：
```cmd
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

### Q4: pnpm 安装失败

尝试清理缓存后重新安装：
```cmd
pnpm store prune
pnpm install
```

### Q5: ffmpeg 找不到

确保 ffmpeg 已添加到系统 PATH 环境变量中，并重启命令提示符。

### Q6: CUDA 不可用

在 Conda 环境中重新安装 PyTorch：
```cmd
conda activate bilinote

# 卸载现有版本
pip uninstall torch torchvision torchaudio

# 使用 conda 安装 CUDA 版本
conda install pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia -y
```

### Q7: 端口被占用

修改 `.env` 文件中的端口配置：
```bash
BACKEND_PORT=8483
FRONTEND_PORT=3015
```

### Q8: 中文路径问题

请确保项目路径不包含中文字符，例如：
- ✅ `C:\Projects\BiliNote`
- ❌ `C:\项目\BiliNote`

### Q9: 如何删除 Conda 环境

```cmd
# 退出环境
conda deactivate

# 删除环境
conda env remove -n bilinote
```

### Q10: 如何查看已安装的 Conda 环境

```cmd
conda env list
```

---

## 目录结构

```
BiliNote/
├── backend/              # 后端代码
│   ├── main.py          # 后端入口
│   └── requirements.txt # Python 依赖
├── BillNote_frontend/   # 前端代码
│   └── package.json     # 前端依赖
├── .env                 # 环境配置
├── environment.yml      # Conda 环境配置（一键安装）
├── start.bat            # Windows 启动脚本
├── stop.bat             # Windows 停止脚本
├── start.sh             # Linux/Mac 启动脚本
└── stop.sh              # Linux/Mac 停止脚本
```

---

## Conda 常用命令速查

```cmd
# 创建环境
conda create -n bilinote python=3.11 -y

# 激活环境
conda activate bilinote

# 退出环境
conda deactivate

# 查看所有环境
conda env list

# 导出环境配置
conda env export > environment.yml

# 从配置文件创建环境
conda env create -f environment.yml

# 删除环境
conda env remove -n bilinote

# 查看已安装的包
conda list

# 安装包
conda install numpy pandas

# 更新 conda
conda update conda
```

---

## 更新日志

- 2026-02-26: 添加 Conda 虚拟环境安装支持
- 2026-02-26: 初始版本，支持 Windows 安装和 CUDA 配置
