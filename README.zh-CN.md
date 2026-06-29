<div align="center">

# 我的技术博客 · My Tech Blog

技术学习与实践笔记

[![Hugo](https://img.shields.io/badge/Hugo-0.140+-FF4088?logo=hugo&logoColor=white)](https://gohugo.io/)
[![Theme](https://img.shields.io/badge/Theme-Hextra-6366f1)](https://github.com/imfing/hextra)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/Deploy-GitHub%20Pages-181717?logo=github)](https://adcwb.github.io/new-docs/)

**简体中文** | [English](README.md)

[📖 在线阅读](https://adcwb.github.io/new-docs/) · [写作规范](CLAUDE.md)

</div>

---

## 项目简介

本站是一个基于 **Hugo + Hextra 主题** 构建的个人技术知识库，涵盖软件开发、系统管理、网络技术与人工智能等核心领域，旨在沉淀技术实践经验、构建可查阅的知识图谱。

## 内容分类

| 栏目 | 涵盖方向 |
| :--- | :------- |
| 🖥️ **软件开发** | Python · Golang · Rust · PHP · Web 前端 |
| 🔧 **系统管理** | Linux 系统运维 · Kubernetes · 云原生 |
| 🌐 **网络技术** | 协议分析 · TCP/IP · Web 安全 · 渗透测试 |
| 🤖 **人工智能** | 机器学习 · 深度学习 · 大语言模型应用 |
| 🗄️ **数据库** | MySQL · PostgreSQL · InfluxDB · SQL Server |
| 📊 **数据分析** | 数据清洗 · 可视化 · 办公自动化 |
| 💰 **金融相关** | 量化分析 · Web3 · 股票 · 期货 |

## 技术栈

- **静态站点生成器**：[Hugo](https://gohugo.io/) v0.140+
- **主题**：[Hextra](https://github.com/imfing/hextra) —— 现代化文档主题，支持暗色模式、全文搜索、数学公式
- **全文搜索**：FlexSearch（离线，无需服务端）
- **数学公式**：MathJax（按需在 front matter 中开启 `math: true`）
- **字体**：Inter（正文）· JetBrains Mono（代码）· Space Grotesk（标题），全部自托管
- **部署**：GitHub Pages（Actions 自动构建）
- **多语言**：中文（默认）+ 英文（`/en/` 路径）

## 本地开发

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

## 写作规范

新增或修改文档请遵循 [CLAUDE.md](CLAUDE.md) 中的规范，要点：

- 所有文章放在 `content/docs/<分类>/` 下
- 每篇文章**必须**包含 YAML front matter（`title`、`weight`、`date`、`tags`）
- 正文从 `##` 开始，不重复写 H1 标题
- 代码块必须标注语言（`go`、`bash`、`python` 等）
- 修改任意中文文章后，必须同步更新对应的 `.en.md` 文件

---

## 许可证

文章内容采用 [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) 协议。
代码与配置文件采用 [MIT](LICENSE) 协议。
