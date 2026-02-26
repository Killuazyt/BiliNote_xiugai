# BiliNote Fast-Whisper + CUDA 加速配置指南

## 目标
配置 fast-whisper 支持 CUDA 加速，同时兼容无 GPU 环境（自动回退到 CPU）

## 支持的 GPU

**所有支持 CUDA 的 NVIDIA GPU 均可使用**，包括但不限于：

| GPU 系列 | 型号示例 | CUDA 支持 |
|----------|----------|-----------|
| **RTX 50 系列** | RTX 5090, 5080, 5070, **5060** | ✅ CUDA 12.x |
| **RTX 40 系列** | RTX 4090, 4080, 4070, **4060**, 4050 | ✅ CUDA 12.x |
| **RTX 30 系列** | RTX 3090, 3080, 3070, 3060, 3050 | ✅ CUDA 11.x/12.x |
| **RTX 20 系列** | RTX 2080, 2070, 2060 | ✅ CUDA 11.x |
| **Tesla/数据中心** | **T4**, V100, A100, A10, A30, H100 | ✅ 全系列支持 |
| **其他 NVIDIA GPU** | 任何支持 CUDA 的 NVIDIA 显卡 | ✅ 自动检测 |

> **核心原理**: 系统通过 `torch.cuda.is_available()` 自动检测，只要 GPU 支持 CUDA 即可启用加速

---

## 步骤 1: 停止现有服务 ✅

```bash
pkill -f "python main.py"
pkill -f "pnpm dev"
```

**状态**: 已完成

---

## 步骤 2: 环境检查 ✅

### 当前环境状态

| 组件 | 版本 | 状态 |
|------|------|------|
| PyTorch | 2.10.0+cu128 | ✅ 已安装（CUDA 支持） |
| faster-whisper | 1.1.1 | ✅ 已安装 |
| ctranslate2 | 4.5.0 | ✅ 已安装（CUDA 支持） |
| GPU | - | ⚠️ 当前环境无 GPU |

### CUDA 支持检测

```
PyTorch CUDA: 可用（但当前无 GPU 设备）
ctranslate2 CUDA: 支持CUDA 加速
```

---

## 步骤 3: CUDA 加速配置

### 3.1 代码自动检测机制

项目代码 (`backend/app/transcriber/whisper.py`) 已内置 GPU/CPU 自动切换：

```python
# 自动检测 CUDA 可用性
self.device = "cuda" if self.is_cuda() else "cpu"

# 自动选择计算类型
self.compute_type = "float16" if self.device == "cuda" else "int8"
```

### 3.2 环境变量配置

`.env` 文件相关配置：

```bash
# 转录器类型
TRANSCRIBER_TYPE=fast-whisper

# 模型大小 (可选: tiny, base, small, medium, large-v1, large-v2, large-v3)
WHISPER_MODEL_SIZE=base
```

### 3.3 CUDA 依赖确认 ✅

当前环境已安装完整的 CUDA 支持库：

```
torch                    2.10.0
nvidia-cublas-cu12       12.8.4.1
nvidia-cuda-runtime-cu12 12.8.90
nvidia-cudnn-cu12        9.10.2.21
nvidia-nccl-cu12         2.27.5
ctranslate2              4.5.0  (支持 CUDA)
```

---

## 步骤 4: GPU/CPU 自动切换机制

### 代码逻辑说明

项目已内置智能检测，**无需手动配置**：

| 环境 | 设备 | 计算类型 | 说明 |
|------|------|----------|------|
| 有 GPU (T4) | cuda | float16 | GPU 加速，速度快 |
| 无 GPU | cpu | int8 | CPU 模式，兼容运行 |

### 检测流程

```
启动后端 → 检测 torch.cuda.is_available()
         → True: 使用 GPU + float16
         → False: 回退 CPU + int8
```

---

## 步骤 5: GPU 优化配置（可选）

### 5.1 根据显存选择模型大小

编辑 `/workspace/BiliNote/.env`：

```bash
# 根据你的 GPU 显存选择合适的模型
WHISPER_MODEL_SIZE=base
```

### 5.2 模型大小与显存需求

| 模型 | 显存需求 (GPU) | 内存需求 (CPU) | 速度 | 精度 | 推荐显卡 |
|------|---------------|---------------|------|------|----------|
| tiny | ~1GB | ~1GB | 最快 | 较低 | 任意 GPU |
| base | ~1GB | ~1GB | 快 | 中等 | 任意 GPU |
| small | ~2GB | ~2GB | 中等 | 较好 | 4GB+ 显存 |
| medium | ~5GB | ~5GB | 较慢 | 好 | 6GB+ 显存 (4060/5060 等) |
| large-v3 | ~10GB | ~10GB | 最慢 | 最好 | 12GB+ 显存 (4070/5070 等) |

### 5.3 显卡推荐配置

| 显卡 | 显存 | 推荐模型 | 说明 |
|------|------|----------|------|
| RTX 5060 / 4060 | 8GB | medium | 平衡速度与精度 |
| RTX 5070 / 4070 | 12GB | large-v3 | 高精度转录 |
| RTX 5080/5090 / 4080/4090 | 16GB+ | large-v3 | 最快最高精度 |
| Tesla T4 | 16GB | medium / large-v3 | 数据中心级 |
| 低显存 GPU (<4GB) | - | base / small | 基础使用 |

### 5.4 更新配置文件 ✅

已更新 `/workspace/BiliNote/.env`：

```bash
# transcriber 相关配置
TRANSCRIBER_TYPE=fast-whisper
WHISPER_MODEL_SIZE=base
```

---

## 步骤 6: 验证配置 ✅

```bash
python3 -c "
from app.utils.env_checker import is_cuda_available, is_torch_installed
print(f'Torch installed: {is_torch_installed()}')
print(f'CUDA available: {is_cuda_available()}')
"
```

**验证结果**:
```
Torch installed: True
CUDA available: False  (当前环境无 GPU)
```

---

## 步骤 7: 配置完成总结

### 环境状态

| 组件 | 状态 | 说明 |
|------|------|------|
| PyTorch + CUDA | ✅ 已配置 | 支持 CUDA 12.8 |
| faster-whisper | ✅ 已配置 | v1.1.1 |
| ctranslate2 | ✅ 已配置 | v4.5.0，支持 CUDA |
| GPU 自动检测 | ✅ 已启用 | 代码内置 |
| CPU 回退 | ✅ 已启用 | 无 GPU 时自动回退 |

### 运行模式

| 环境 | 设备 | 计算类型 | 启动提示 |
|------|------|----------|----------|
| 任何 CUDA GPU (RTX 5060/4060/T4 等) | cuda | float16 | "CUDA 可用，使用 GPU" |
| 无 GPU | cpu | int8 | "只装了 torch，但没有 CUDA，用 CPU" |

---

## 步骤 8: 启动服务验证 ✅

```bash
cd /workspace/BiliNote/backend
python main.py
```

**启动日志**:
```
Starting server on 0.0.0.0:8483
初始化转录服务提供器
请求转录器类型: fast-whisper
只装了 torch，但没有 CUDA，用 CPU  ← 当前无 GPU，使用 CPU 模式
```

**服务状态**: 后端运行在 http://127.0.0.1:8483

---

## 配置完成 ✅

### 关键配置点

1. **CUDA 加速已就绪**: 所有依赖已安装，支持 CUDA 12.8
2. **自动切换机制**: 代码内置 GPU/CPU 自动检测
3. **全 GPU 兼容**: 支持任何 CUDA 兼容的 NVIDIA GPU（RTX 5060/4060/4070/T4 等）
4. **CPU 回退**: 无 GPU 环境自动使用 int8 量化

### 在 GPU 环境运行

当部署到任何 CUDA GPU 环境时（RTX 5060/4060/T4 等）：
1. 系统会自动检测到 CUDA 可用
2. 使用 `cuda` 设备 + `float16` 计算类型
3. 转录速度相比 CPU 提升约 5-10 倍

### 修改模型大小

如需更高精度，编辑 `.env`：
```bash
WHISPER_MODEL_SIZE=medium  # 或 large-v3
```

---

## 参考链接

- [faster-whisper GitHub](https://github.com/SYSTRAN/faster-whisper)
- [ctranslate2 CUDA 支持](https://opennmt.net/CTranslate2/python/ctranslate2.html)
- [NVIDIA CUDA 兼容列表](https://developer.nvidia.com/cuda-gpus)

---

## 快速启动

```bash
cd /workspace/BiliNote
./start.sh
```
