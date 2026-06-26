<div align="center">

# 我的技术博客 · My Tech Blog

**技术学习与实践笔记 · Notes on Tech Learning & Practice**

[![Hugo](https://img.shields.io/badge/Hugo-0.140+-FF4088?logo=hugo&logoColor=white)](https://gohugo.io/)
[![Theme](https://img.shields.io/badge/Theme-Hextra-6366f1)](https://github.com/imfing/hextra)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/Deploy-GitHub%20Pages-181717?logo=github)](https://adcwb.github.io/new-docs/)

[📖 在线阅读](https://adcwb.github.io/new-docs/) · [English](#english-readme) · [写作规范](CLAUDE.md)

</div>

---

## 中文说明

### 项目简介

本站是一个基于 **Hugo + Hextra 主题** 构建的个人技术知识库，涵盖软件开发、系统管理、网络技术与人工智能等核心领域，旨在沉淀技术实践经验、构建可查阅的知识图谱。

### 内容分类

| 栏目 | 涵盖方向 |
|------|---------|
| 🖥️ **软件开发** | Python · Golang · Rust · PHP · Web 前端 |
| 🔧 **系统管理** | Linux 系统运维 · Kubernetes · 云原生 |
| 🌐 **网络技术** | 协议分析 · TCP/IP · Web 安全 · 渗透测试 |
| 🤖 **人工智能** | 机器学习 · 深度学习 · 大语言模型应用 |
| 🗄️ **数据库** | MySQL · PostgreSQL · InfluxDB · SQL Server |
| 📊 **数据分析** | 数据清洗 · 可视化 · 办公自动化 |
| 💰 **金融相关** | 量化分析 · Web3 · 股票 · 期货 |

### 技术栈

- **静态站点生成器**：[Hugo](https://gohugo.io/) v0.140+
- **主题**：[Hextra](https://github.com/imfing/hextra) —— 现代化文档主题，支持暗色模式、全文搜索、数学公式
- **全文搜索**：FlexSearch（离线，无需服务端）
- **数学公式**：MathJax（按需在 front matter 中开启 `math: true`）
- **字体**：Inter（正文）· JetBrains Mono（代码）· Space Grotesk（标题），全部自托管
- **部署**：GitHub Pages（Actions 自动构建）
- **多语言**：中文（默认）+ 英文（`/en/` 路径）

### 本地开发

**前置要求**：Go 1.21+、Hugo Extended v0.140+

```bash
# 1. 克隆仓库
git clone https://github.com/adcwb/new-docs.git
cd new-docs

# 2. 拉取 Hugo 模块（Hextra 主题）
hugo mod tidy

# 3. 启动本地开发服务器（含热重载）
hugo server -D

# 4. 访问 http://localhost:1313
```

**构建生产版本**：

```bash
hugo --gc --minify
# 产出物位于 public/
```

### 写作规范

新增或修改文档请遵循 [CLAUDE.md](CLAUDE.md) 中的规范，要点：

- 所有文章放在 `content/docs/<分类>/` 下
- 每篇文章**必须**包含 YAML front matter（`title`、`weight`、`date`）
- 正文从 `##` 开始，不重复写 H1 标题
- 代码块必须标注语言（`go`、`bash`、`python` 等）
- 禁止 Typora 专有写法（`[toc]`、全角空格缩进等）

### GitHub 仓库配置建议

在 GitHub 仓库页面右上角 **About（齿轮图标）** 处填入：

- **Description**：`技术学习与实践笔记 | Hugo + Hextra 技术博客，涵盖软件开发、系统管理、网络安全与 AI`
- **Website**：`https://adcwb.github.io/new-docs/`
- **Topics**：`hugo` `hextra` `blog` `docs` `python` `golang` `linux` `kubernetes` `machine-learning` `security`

---

## English README

### Overview

A personal technical knowledge base built with **Hugo + Hextra**, covering software development, system administration, networking, and artificial intelligence. The goal is to document hands-on technical experience in a structured, searchable format.

### Content Categories

| Section | Topics |
|---------|--------|
| 🖥️ **Software Dev** | Python · Golang · Rust · PHP · Web Frontend |
| 🔧 **Systems** | Linux Administration · Kubernetes · Cloud Native |
| 🌐 **Networking** | Protocol Analysis · TCP/IP · Web Security · Pentesting |
| 🤖 **AI** | Machine Learning · Deep Learning · LLM Applications |
| 🗄️ **Databases** | MySQL · PostgreSQL · InfluxDB · SQL Server |
| 📊 **Data Analysis** | Data Cleaning · Visualization · Office Automation |
| 💰 **Finance** | Quant Analysis · Web3 · Stocks · Futures |

### Tech Stack

- **Generator**: [Hugo](https://gohugo.io/) v0.140+
- **Theme**: [Hextra](https://github.com/imfing/hextra) — modern docs theme with dark mode, full-text search, math rendering
- **Search**: FlexSearch (offline, client-side)
- **Math**: MathJax (enable per-page with `math: true` in front matter)
- **Fonts**: Inter (body) · JetBrains Mono (code) · Space Grotesk (headings), all self-hosted
- **Deployment**: GitHub Pages via GitHub Actions
- **i18n**: Chinese (default) + English (`/en/` path)

### Local Development

**Requirements**: Go 1.21+, Hugo Extended v0.140+

```bash
# Clone the repo
git clone https://github.com/adcwb/new-docs.git
cd new-docs

# Download Hugo modules (Hextra theme)
hugo mod tidy

# Start dev server with hot reload
hugo server -D

# Open http://localhost:1313
```

**Build for production**:

```bash
hugo --gc --minify
# Output is in public/
```

### Writing Guidelines

See [CLAUDE.md](CLAUDE.md) for the full style guide. Key rules:

- All articles live under `content/docs/<category>/`
- Every article **must** have YAML front matter (`title`, `weight`, `date`)
- Body content starts at `##` — do not repeat H1 from the title
- Code blocks must specify a language tag
- No Typora-specific syntax (`[toc]`, full-width space indents, etc.)

### GitHub Repository Setup

Fill in the **About** section (gear icon on the repo page):

- **Description**: `Personal tech notes | Hugo + Hextra blog covering software dev, Linux, networking & AI`
- **Website**: `https://adcwb.github.io/new-docs/`
- **Topics**: `hugo` `hextra` `blog` `docs` `python` `golang` `linux` `kubernetes` `machine-learning` `security`

---

## License

Content is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
Code and configuration are licensed under [MIT](LICENSE).
