---
title: "Anaconda 使用指南"
weight: 10
date: 2026-06-27
tags: ["Python", "Anaconda", "Conda", "虚拟环境", "Jupyter"]
---

Anaconda 是面向数据科学的 Python/R 发行版，内置了 Conda 包管理器、数百个常用科学计算包，以及 Jupyter Notebook 开发环境。它最核心的价值在于**虚拟环境隔离**：不同项目可以维护各自独立的 Python 版本和依赖，互不干扰。

本文覆盖 Conda 环境管理、包管理、Jupyter 使用技巧，以及常见问题排查。

## 安装与初始配置

从 [anaconda.com](https://www.anaconda.com/download) 下载对应平台的安装包，安装时注意：

{{< callout type="warning" >}}
安装路径不能包含中文或特殊符号，否则部分包会报路径解析错误。安装时勾选"Add Anaconda to PATH"，省去手动配置环境变量的步骤。
{{< /callout >}}

安装完成后，在终端验证：

```bash
python -V           # 查看 Python 版本
conda --version     # 查看 Conda 版本
jupyter --version   # 查看 Jupyter 版本
```

### 配置国内镜像源

国内网络访问 Anaconda 默认源较慢，推荐切换到清华镜像：

```bash
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --set show_channel_urls yes

# 验证配置
conda config --show channels
```

## 虚拟环境管理

### 创建环境

```bash
# 指定 Python 版本
conda create -n myenv python=3.11

# 创建时同时安装常用包
conda create -n data python=3.11 numpy pandas matplotlib -y
```

{{< callout type="info" >}}
`-n` 指定环境名称。默认安装位置由 `conda config --show envs_dirs` 决定，也可以用 `-p /path/to/env` 指定自定义路径。
{{< /callout >}}

### 查看、激活与删除

```bash
# 查看所有环境
conda env list

# 激活 / 退出
conda activate myenv
conda deactivate

# 删除整个环境
conda remove -n myenv --all

# 删除环境中某个包
conda remove -n myenv numpy
```

### 环境迁移与共享

团队协作时，通过 `environment.yml` 共享环境配置：

```bash
# 导出当前环境
conda env export > environment.yml

# 在新机器上还原
conda env create -f environment.yml
```

离线迁移（把整个环境打包复制）：

```bash
pip install conda-pack
conda pack -n myenv          # 生成 myenv.tar.gz
tar -xzf myenv.tar.gz -C /opt/myenv  # 目标机器解压
```

## 包管理

### 安装与卸载

```bash
# conda 安装（不需要先激活环境）
conda install -n myenv numpy

# 激活后用 pip 安装（pip 必须在激活状态下使用）
conda activate myenv
pip install requests

# 更新 / 卸载
conda update numpy
conda remove numpy
pip uninstall numpy
```

{{< callout type="info" >}}
`conda install` 会自动解决依赖冲突，且可以不激活环境直接为指定环境安装；`pip` 则需要先激活目标环境，只管理当前 Python 的包。两者可以混用，但优先用 `conda`。
{{< /callout >}}

### 查看与搜索

```bash
conda list                  # 列出当前环境所有包
conda search pandas         # 搜索包（支持模糊匹配）
conda update --all          # 更新当前环境所有包
conda update -n base conda  # 更新 Conda 自身
```

## Jupyter Notebook

### 启动

```bash
jupyter notebook                  # 默认端口 8888
jupyter notebook --port 8889      # 指定端口
jupyter notebook --no-browser     # 只启动服务，不打开浏览器
```

### 单元格类型与快捷键

Jupyter 的基本单位是**单元格（Cell）**，分两种：

- **Code Cell**：写代码，`Shift+Enter` 执行
- **Markdown Cell**：写文档，`Shift+Enter` 渲染

常用快捷键（命令模式，先按 `Esc`）：

| 快捷键 | 功能 |
| :--- | :--- |
| `A` | 在上方插入单元格 |
| `B` | 在下方插入单元格 |
| `X` | 删除当前单元格 |
| `Z` | 撤销删除 |
| `Y` | 切换为 Code 类型 |
| `M` | 切换为 Markdown 类型 |
| `Shift+Enter` | 运行并跳到下一格 |
| `Ctrl+Enter` | 运行，留在当前格 |

### 为虚拟环境注册内核

默认情况下 Jupyter 只能使用 base 环境的内核。要在 Jupyter 中切换到某个虚拟环境，需注册内核：

```bash
conda activate myenv
pip install ipykernel
python -m ipykernel install --name myenv --display-name "Python (myenv)"

# 查看已注册的内核
jupyter kernelspec list

# 删除不再需要的内核
jupyter kernelspec remove myenv
```

之后在 Jupyter 界面的 **Kernel → Change kernel** 菜单中即可选择该环境。

### 魔法命令

Jupyter 提供以 `%` 或 `%%` 开头的魔法命令，在代码单元格中直接使用：

```python
%timeit sum(range(10000))     # 对单行代码计时
%%timeit                       # 对整个单元格计时
for i in range(10000):
    pass

%matplotlib inline            # 在 Notebook 内嵌显示图表
%run script.py                # 执行外部脚本
%load_ext autoreload          # 开启模块热重载
%autoreload 2
```

## 完整工作流示例

以下是从创建环境到运行分析的完整流程：

{{< steps >}}

### 创建并激活环境

```bash
conda create -n analysis python=3.11 pandas numpy matplotlib seaborn jupyter -y
conda activate analysis
```

### 注册 Jupyter 内核

```bash
python -m ipykernel install --name analysis --display-name "Data Analysis"
```

### 启动 Jupyter 并编写分析代码

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

%matplotlib inline

data = pd.read_csv("dataset.csv")
data.describe()
```

### 导出环境配置，方便复现

```bash
conda env export > environment.yml
```

{{< /steps >}}

## 常见问题

**激活环境后命令仍用的是 base Python**：检查是否已执行 `conda init` 并重启终端。Windows 上建议用 Anaconda Prompt 而非系统 PowerShell。

**包安装卡在 Solving environment**：更换镜像源（见上文），或用 `--no-channel-priority` 参数降低依赖解析严格度。

**Jupyter 中看不到注册的内核**：确认 `ipykernel` 安装在目标虚拟环境中，而非 base 中，然后重启 Jupyter 服务。
