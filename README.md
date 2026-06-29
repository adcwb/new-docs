<div align="center">

# My Tech Blog · 我的技术博客

Personal tech notes on software dev, Linux, networking & AI

[![Hugo](https://img.shields.io/badge/Hugo-0.140+-FF4088?logo=hugo&logoColor=white)](https://gohugo.io/)
[![Theme](https://img.shields.io/badge/Theme-Hextra-6366f1)](https://github.com/imfing/hextra)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![GitHub Pages](https://img.shields.io/badge/Deploy-GitHub%20Pages-181717?logo=github)](https://adcwb.github.io/new-docs/)

[简体中文](README.zh-CN.md) | **English**

[📖 Live Site](https://adcwb.github.io/new-docs/) · [Writing Guidelines](CLAUDE.md)

</div>

---

## Overview

A personal technical knowledge base built with **Hugo + Hextra**, covering software development, system administration, networking, and artificial intelligence. The goal is to document hands-on technical experience in a structured, searchable format.

## Content Categories

| Section | Topics |
| :------ | :----- |
| 🖥️ **Software Dev** | Python · Golang · Rust · PHP · Web Frontend |
| 🔧 **Systems** | Linux Administration · Kubernetes · Cloud Native |
| 🌐 **Networking** | Protocol Analysis · TCP/IP · Web Security · Pentesting |
| 🤖 **AI** | Machine Learning · Deep Learning · LLM Applications |
| 🗄️ **Databases** | MySQL · PostgreSQL · InfluxDB · SQL Server |
| 📊 **Data Analysis** | Data Cleaning · Visualization · Office Automation |
| 💰 **Finance** | Quant Analysis · Web3 · Stocks · Futures |

## Tech Stack

- **Generator**: [Hugo](https://gohugo.io/) v0.140+
- **Theme**: [Hextra](https://github.com/imfing/hextra) — modern docs theme with dark mode, full-text search, math rendering
- **Search**: FlexSearch (offline, client-side)
- **Math**: MathJax (enable per-page with `math: true` in front matter)
- **Fonts**: Inter (body) · JetBrains Mono (code) · Space Grotesk (headings), all self-hosted
- **Deployment**: GitHub Pages via GitHub Actions
- **i18n**: Chinese (default) + English (`/en/` path)

## Local Development

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

## Writing Guidelines

See [CLAUDE.md](CLAUDE.md) for the full style guide. Key rules:

- All articles live under `content/docs/<category>/`
- Every article **must** have YAML front matter (`title`, `weight`, `date`, `tags`)
- Body content starts at `##` — do not repeat H1 from the title
- Code blocks must specify a language tag
- No Typora-specific syntax (`[toc]`, full-width space indents, etc.)
- When modifying any Chinese article, always sync the paired `.en.md` file

---

## License

Content is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
Code and configuration are licensed under [MIT](LICENSE).
