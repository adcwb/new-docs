<#
.SYNOPSIS
    Generates .en.md stub files for all untranslated content in content/docs/.
.DESCRIPTION
    - Scans every *.md file (excluding *.en.md) under content/docs/
    - Skips files that already have a .en.md counterpart
    - For _index.md: uses explicit English content where defined, otherwise generates
      a minimal section stub with a translated title
    - For article files: generates a stub with a "translation in progress" notice
    - All files are written UTF-8 without BOM
.EXAMPLE
    cd d:\Projects\Docs\new-docs
    .\scripts\generate-en.ps1
#>

param(
    [string]$ProjectRoot = $PSScriptRoot | Split-Path
)

$docsDir = Join-Path $ProjectRoot "content\docs"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$created = 0
$skipped = 0

# ── Title translation dictionary ────────────────────────────────────────────
$titleMap = [ordered]@{
    # Top-level categories
    "软件开发"       = "Software Development"
    "系统管理"       = "System Administration"
    "网络技术"       = "Networking"
    "人工智能"       = "Artificial Intelligence"
    "数据库"         = "Databases"
    "数据分析"       = "Data Analysis"
    "金融相关"       = "Finance & Trading"
    "Markdown语法"   = "Markdown Syntax"
    # Software Dev sub-sections
    "Python开发"     = "Python Development"
    "Golang开发"     = "Golang Development"
    "Rust开发"       = "Rust Development"
    "PHP开发"        = "PHP Development"
    "Web开发"        = "Web Development"
    # Python sub-sections
    "Python基础"     = "Python Fundamentals"
    "Python框架"     = "Python Frameworks"
    "Python测试"     = "Python Testing"
    "Python爬虫"     = "Web Scraping"
    "Python网络编程" = "Python Networking"
    "py小工具"       = "Python Utilities"
    "drf课件(新版)"  = "DRF Course"
    # Go sub-sections
    "基础"           = "Fundamentals"
    "框架"           = "Frameworks"
    "插件"           = "Plugins"
    "模型"           = "Models & Patterns"
    "进阶"           = "Advanced"
    # PHP sub-sections
    "PHP基础"        = "PHP Fundamentals"
    "PHP数据库"      = "PHP & Databases"
    "PHP框架"        = "PHP Frameworks"
    # System Administration
    "Linux系统"      = "Linux Systems"
    "云原生"         = "Cloud Native"
    "系统服务"       = "System Services"
    "常用命令"       = "Common Commands"
    # Networking
    "安全"           = "Security"
    "Kali渗透"       = "Kali Pentesting"
    "Web安全"        = "Web Security"
    "WiFi安全"       = "WiFi Security"
    "漏洞挖掘"       = "Vulnerability Research"
    # AI
    "机器学习基础"   = "Machine Learning"
    "深度学习基础"   = "Deep Learning"
    "大模型应用"     = "LLM Applications"
    # Data Analysis
    "业务数据分析"   = "Business Analytics"
    "办公自动化"     = "Office Automation"
    # Misc
    "概览"           = "Overview"
}

# ── Explicit English content for key section _index.md files ────────────────
# Key: relative path from docsDir using forward slashes, pointing to the SOURCE Chinese file
$explicitContent = @{}

$explicitContent["_index.md"] = @"
---
title: "Overview"
weight: 1
toc: false
---

This is the main entry point for all technical notes. Content is organized into **four major tracks** — Software Development, System Administration, Networking, and Artificial Intelligence — plus standalone topics. Click any module to jump in, or use the top navigation bar, or press Ctrl K to search.

## Software Development

Applications and services: programming languages, web frameworks, and engineering practice.

{{< cards >}}
  {{< card link="软件开发/python开发/" title="Python" icon="code" subtitle="Syntax, web frameworks, scraping, and engineering practice" >}}
  {{< card link="软件开发/golang开发/" title="Golang" icon="lightning-bolt" subtitle="Concurrency, standard library, and high-performance services" >}}
  {{< card link="软件开发/rust开发/" title="Rust" icon="cog" subtitle="Ownership, lifetimes, memory safety, and systems programming" >}}
  {{< card link="软件开发/php开发/" title="PHP" icon="server" subtitle="Language features, popular frameworks, and web backends" >}}
  {{< card link="软件开发/web开发/" title="Web" icon="globe-alt" subtitle="Frontend engineering, HTTP protocol, and API design" >}}
{{< /cards >}}

## System Administration

Systems and infrastructure: from single-machine Linux operations to container orchestration.

{{< cards >}}
  {{< card link="系统管理/linux系统/" title="Linux Systems" icon="terminal" subtitle="System services, Shell scripting, networking, and troubleshooting" >}}
  {{< card link="系统管理/云原生/" title="Cloud Native" icon="cloud" subtitle="Kubernetes, container orchestration, and observability" >}}
{{< /cards >}}

## Networking

Protocols and security: how data flows across networks and how to guard every gateway.

{{< cards >}}
  {{< card link="网络技术/网络技术/" title="Networking" icon="globe" subtitle="TCP/IP, protocol analysis, routing, switching, and troubleshooting" >}}
  {{< card link="网络技术/安全/" title="Security" icon="shield-check" subtitle="Web security, offensive/defensive practice, and system hardening" >}}
{{< /cards >}}

## Artificial Intelligence

From algorithmic foundations to large model applications.

{{< cards >}}
  {{< card link="人工智能/机器学习基础/" title="Machine Learning" icon="chart-bar" subtitle="Supervised learning, model evaluation, feature engineering, and classic algorithms" >}}
  {{< card link="人工智能/深度学习基础/" title="Deep Learning" icon="chip" subtitle="Neural networks, CNN/RNN, training, and optimization" >}}
  {{< card link="人工智能/大模型应用/" title="LLM Applications" icon="sparkles" subtitle="Large language models, prompt engineering, and production deployment" >}}
{{< /cards >}}

## Standalone Topics

{{< cards >}}
  {{< card link="数据库/" title="Databases" icon="database" subtitle="MySQL / PostgreSQL / InfluxDB design, tuning, and indexing" >}}
  {{< card link="数据分析/" title="Data Analysis" icon="chart-bar" subtitle="Data cleaning, visualization, and analytical methodology" >}}
  {{< card link="金融相关/" title="Finance & Trading" icon="currency-dollar" subtitle="Stocks, futures, Web3, and quantitative analysis" >}}
  {{< card link="markdown语法/" title="Markdown Syntax" icon="document-text" subtitle="Lightweight markup for technical writing and documentation" >}}
{{< /cards >}}
"@

$explicitContent["软件开发/_index.md"] = @"
---
title: "Software Development"
weight: 1
---

Focused on application and service development: mainstream programming languages, web frameworks, protocols, and engineering practice. Each module walks from foundational syntax to production patterns.

{{< cards >}}
  {{< card link="python开发/" title="Python" icon="code" subtitle="Syntax, web frameworks (Django/Flask/DRF), scraping, and engineering practice" >}}
  {{< card link="golang开发/" title="Golang" icon="lightning-bolt" subtitle="Concurrency model, standard library, and high-performance services" >}}
  {{< card link="rust开发/" title="Rust" icon="cog" subtitle="Ownership and lifetimes, memory safety, and systems programming" >}}
  {{< card link="php开发/" title="PHP" icon="server" subtitle="Language features, popular frameworks, and web backends" >}}
  {{< card link="web开发/" title="Web" icon="globe-alt" subtitle="Frontend engineering, HTTP protocol, and API design" >}}
{{< /cards >}}
"@

$explicitContent["系统管理/_index.md"] = @"
---
title: "System Administration"
weight: 2
---

Systems and infrastructure: from single-machine Linux operations to container orchestration and observability. Covers service deployment, troubleshooting, and stability practices.

{{< cards >}}
  {{< card link="linux系统/" title="Linux Systems" icon="terminal" subtitle="System services, Shell scripting, networking, and operational troubleshooting" >}}
  {{< card link="云原生/" title="Cloud Native" icon="cloud" subtitle="Kubernetes, container orchestration, and observability" >}}
{{< /cards >}}
"@

$explicitContent["网络技术/_index.md"] = @"
---
title: "Networking"
weight: 3
---

From protocols to offense and defense: understand how data flows across networks and how to secure every layer. Covers the TCP/IP stack, routing and switching, web security, and system hardening.

{{< cards >}}
  {{< card link="网络技术/" title="Network Fundamentals" icon="globe" subtitle="TCP/IP, protocol analysis, routing, switching, and troubleshooting" >}}
  {{< card link="安全/" title="Security" icon="shield-check" subtitle="Web security, offensive/defensive practice, and system hardening" >}}
{{< /cards >}}
"@

$explicitContent["人工智能/_index.md"] = @"
---
title: "Artificial Intelligence"
weight: 4
---

From machine learning fundamentals to large model applications: understand the algorithms and put models into production.

{{< cards >}}
  {{< card link="机器学习基础/" title="Machine Learning" icon="chart-bar" subtitle="Supervised learning, model evaluation, feature engineering, and classic algorithms" >}}
  {{< card link="深度学习基础/" title="Deep Learning" icon="chip" subtitle="Neural networks, CNN/RNN, training, and optimization" >}}
  {{< card link="大模型应用/" title="LLM Applications" icon="sparkles" subtitle="Large language models, prompt engineering, and production deployment" >}}
{{< /cards >}}
"@

$explicitContent["数据库/_index.md"] = @"
---
title: "Databases"
weight: 6
---

Relational and time-series databases: schema design, query optimization, indexing, and performance tuning.

{{< cards >}}
  {{< card link="MySql数据库/" title="MySQL" icon="database" subtitle="Schema design, query optimization, indexes, and transactions" >}}
  {{< card link="PostgreSQL/" title="PostgreSQL" icon="database" subtitle="Advanced SQL, extensions, and performance tuning" >}}
  {{< card link="InfluxDB/" title="InfluxDB" icon="database" subtitle="Time-series data storage and Flux query language" >}}
  {{< card link="SQLServer/" title="SQL Server" icon="database" subtitle="Windows-ecosystem SQL Server operations and administration" >}}
{{< /cards >}}
"@

$explicitContent["数据分析/_index.md"] = @"
---
title: "Data Analysis"
weight: 7
---

Data cleaning, visualization, business analytics, and office automation with Python.

{{< cards >}}
  {{< card link="业务数据分析/" title="Business Analytics" icon="chart-bar" subtitle="Data cleaning, visualization, and analytical methodology" >}}
  {{< card link="办公自动化/" title="Office Automation" icon="document-text" subtitle="Python-powered office automation workflows" >}}
{{< /cards >}}
"@

$explicitContent["金融相关/_index.md"] = @"
---
title: "Finance & Trading"
weight: 8
---

Quantitative analysis, financial instruments, stock markets, futures, and Web3 fundamentals.
"@

$explicitContent["Markdown语法/_index.md"] = @"
---
title: "Markdown Syntax"
weight: 9
---

Lightweight markup language reference for technical writing and documentation formatting.
"@

$explicitContent["软件开发/Python开发/_index.md"] = @"
---
title: "Python Development"
weight: 1
date: 2026-06-23
---

This module covers Python development from fundamentals to advanced topics, based on **Python 3.13**. Topics include syntax, data types, functions and modules, OOP, concurrency, major frameworks (Django / Flask / Tornado), web scraping, network programming, testing, and common developer tools.

{{< cards >}}
  {{< card link="Python基础/" title="Python Fundamentals" icon="code" subtitle="Syntax, data types, functions, modules, and OOP" >}}
  {{< card link="Python框架/" title="Python Frameworks" icon="server" subtitle="Django, Flask, Tornado, DRF" >}}
  {{< card link="Python爬虫/" title="Web Scraping" icon="globe" subtitle="Requests, BeautifulSoup, Scrapy, and anti-scraping techniques" >}}
  {{< card link="Python网络编程/" title="Network Programming" icon="globe-alt" subtitle="Sockets, asyncio, and network protocols" >}}
  {{< card link="Python测试/" title="Testing" icon="check-circle" subtitle="unittest, pytest, and test-driven development" >}}
  {{< card link="py小工具/" title="Utilities" icon="cog" subtitle="Handy Python scripts and productivity tools" >}}
{{< /cards >}}
"@

$explicitContent["软件开发/Golang开发/_index.md"] = @"
---
title: "Golang Development"
weight: 2
---

Go programming from fundamentals to production services: concurrency model, standard library, frameworks, and plugins.

{{< cards >}}
  {{< card link="基础/" title="Fundamentals" icon="code" subtitle="Syntax, types, goroutines, channels, and standard library" >}}
  {{< card link="框架/" title="Frameworks" icon="server" subtitle="Gin, Echo, and other Go web frameworks" >}}
  {{< card link="插件/" title="Plugins" icon="cog" subtitle="Go plugin ecosystem and extensions" >}}
  {{< card link="模型/" title="Models & Patterns" icon="template" subtitle="Design patterns and architectural models in Go" >}}
{{< /cards >}}
"@

$explicitContent["软件开发/Rust开发/_index.md"] = @"
---
title: "Rust Development"
weight: 3
---

Systems programming with Rust: ownership, lifetimes, memory safety, and production frameworks.

{{< cards >}}
  {{< card link="基础/" title="Fundamentals" icon="code" subtitle="Ownership, lifetimes, borrowing, and core syntax" >}}
  {{< card link="框架/" title="Frameworks" icon="server" subtitle="Actix, Axum, and other Rust frameworks" >}}
  {{< card link="进阶/" title="Advanced" icon="chip" subtitle="Unsafe Rust, macros, async, and performance optimization" >}}
{{< /cards >}}
"@

$explicitContent["软件开发/PHP开发/_index.md"] = @"
---
title: "PHP Development"
weight: 4
---

PHP web development: language fundamentals, database integration, and popular frameworks.

{{< cards >}}
  {{< card link="PHP基础/" title="PHP Fundamentals" icon="code" subtitle="Syntax, types, functions, and OOP" >}}
  {{< card link="PHP数据库/" title="PHP & Databases" icon="database" subtitle="PDO, MySQL integration, and ORM usage" >}}
  {{< card link="PHP框架/" title="PHP Frameworks" icon="server" subtitle="Laravel, Symfony, and other PHP frameworks" >}}
{{< /cards >}}
"@

$explicitContent["软件开发/Web开发/_index.md"] = @"
---
title: "Web Development"
weight: 5
---

Frontend engineering: JavaScript frameworks, HTTP protocol, and API design patterns.

{{< cards >}}
  {{< card link="React/" title="React" icon="code" subtitle="Component model, hooks, state management, and ecosystem" >}}
  {{< card link="Vue/" title="Vue" icon="code" subtitle="Vue 3, Composition API, and Vite" >}}
  {{< card link="Angular/" title="Angular" icon="code" subtitle="TypeScript-first framework for large-scale apps" >}}
{{< /cards >}}
"@

$explicitContent["系统管理/Linux系统/_index.md"] = @"
---
title: "Linux Systems"
weight: 8
---

Linux system administration: services, Shell scripting, networking, and operational troubleshooting.

{{< cards >}}
  {{< card link="系统服务/" title="System Services" icon="server" subtitle="systemd, service management, and daemon configuration" >}}
{{< /cards >}}
"@

$explicitContent["系统管理/云原生/_index.md"] = @"
---
title: "Cloud Native"
weight: 9
---

Kubernetes and cloud-native infrastructure: container orchestration, observability, and cloud-native design patterns.
"@

$explicitContent["网络技术/网络技术/_index.md"] = @"
---
title: "Network Fundamentals"
weight: 1
---

TCP/IP protocol stack, protocol analysis, routing, switching, and network troubleshooting.

{{< cards >}}
  {{< card link="进阶/" title="Advanced Networking" icon="globe" subtitle="Advanced protocols, traffic analysis, and network engineering" >}}
{{< /cards >}}
"@

$explicitContent["网络技术/安全/_index.md"] = @"
---
title: "Security"
weight: 2
---

Offensive and defensive security: web application vulnerabilities, penetration testing, vulnerability research, and system hardening.

{{< cards >}}
  {{< card link="Web安全/" title="Web Security" icon="shield-check" subtitle="OWASP Top 10, XSS, SQLi, CSRF, and secure coding" >}}
  {{< card link="Kali渗透/" title="Kali Pentesting" icon="terminal" subtitle="Penetration testing tools, methodology, and CTF practice" >}}
  {{< card link="WiFi安全/" title="WiFi Security" icon="wifi" subtitle="WPA/WPA2 analysis, wireless pentesting, and hardening" >}}
  {{< card link="漏洞挖掘/" title="Vulnerability Research" icon="search" subtitle="Fuzzing, static analysis, and CVE research methodology" >}}
{{< /cards >}}
"@

$explicitContent["人工智能/机器学习基础/_index.md"] = @"
---
title: "Machine Learning"
weight: 1
---

Supervised and unsupervised learning: theory, model evaluation, feature engineering, and classic algorithms.
"@

$explicitContent["人工智能/深度学习基础/_index.md"] = @"
---
title: "Deep Learning"
weight: 2
---

Neural networks from perceptrons to transformers: CNN, RNN, attention mechanisms, training strategies, and optimization techniques.
"@

$explicitContent["人工智能/大模型应用/_index.md"] = @"
---
title: "LLM Applications"
weight: 3
---

Large language models in production: prompt engineering, RAG pipelines, fine-tuning, agent frameworks, and deployment patterns.
"@

$explicitContent["软件开发/Python开发/Python框架/_index.md"] = @"
---
title: "Python Frameworks"
weight: 2
---

Python web frameworks: Django, Flask, Tornado, and the Django REST Framework.

{{< cards >}}
  {{< card link="Django/" title="Django" icon="server" subtitle="Full-featured web framework with ORM, admin, and auth" >}}
  {{< card link="DRF/" title="DRF" icon="server" subtitle="Django REST Framework for building APIs" >}}
  {{< card link="flask/" title="Flask" icon="server" subtitle="Lightweight WSGI web application framework" >}}
  {{< card link="tornado/" title="Tornado" icon="server" subtitle="Async networking framework for high-concurrency apps" >}}
{{< /cards >}}
"@

$explicitContent["数据分析/业务数据分析/_index.md"] = @"
---
title: "Business Analytics"
weight: 1
---

Business data analysis: data cleaning, exploratory analysis, visualization, and reporting with Python and pandas.
"@

$explicitContent["数据分析/办公自动化/_index.md"] = @"
---
title: "Office Automation"
weight: 2
---

Automate repetitive office tasks with Python: Excel/Word processing, email automation, PDF generation, and more.
"@

# ── Helper: translate a title using the dictionary ──────────────────────────
function Translate-Title([string]$zh) {
    if (-not $zh) { return "Untitled" }
    $clean = $zh.Trim('"', "'").Trim()
    if ($titleMap.Contains($clean)) { return $titleMap[$clean] }
    # Try substring replacement
    $result = $clean
    foreach ($key in $titleMap.Keys) {
        if ($result.Contains($key)) {
            $result = $result.Replace($key, $titleMap[$key])
        }
    }
    return $result
}

# ── Helper: extract a single YAML front-matter value ────────────────────────
function Get-FM([string]$raw, [string]$key) {
    if ($raw -match "(?m)^${key}:\s*[`"']?(.+?)[`"']?\s*$") {
        return $matches[1].Trim('"', "'").Trim()
    }
    return $null
}

# ── Helper: rebuild front matter for the English stub ───────────────────────
function Build-FM([string]$enTitle, [string]$weight, [string]$date, [string[]]$extras) {
    $lines = @("---", "title: `"$enTitle`"")
    if ($weight) { $lines += "weight: $weight" }
    if ($date)   { $lines += "date: $date" }
    foreach ($e in $extras) { if ($e) { $lines += $e } }
    $lines += "---"
    return ($lines -join "`n") + "`n"
}

# ── Main loop ────────────────────────────────────────────────────────────────
$files = Get-ChildItem -Path $docsDir -Recurse -Filter "*.md" |
    Where-Object { $_.Name -notmatch "\.en\.md$" } |
    Sort-Object FullName

foreach ($file in $files) {
    # Determine target .en.md path
    if ($file.Name -eq "_index.md") {
        $enPath = Join-Path $file.DirectoryName "_index.en.md"
    } else {
        $enPath = Join-Path $file.DirectoryName ($file.BaseName + ".en.md")
    }

    if (Test-Path $enPath) { $skipped++; continue }

    # Relative path from docsDir (forward slashes) for lookup
    $relPath = $file.FullName.Substring($docsDir.Length).TrimStart('\', '/').Replace('\', '/')

    $raw = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)

    # ── Case 1: explicit content defined for this file ───────────────────
    if ($explicitContent.ContainsKey($relPath)) {
        $body = $explicitContent[$relPath]
        [System.IO.File]::WriteAllText($enPath, $body, $utf8NoBom)
        $created++
        Write-Host "  [explicit] $relPath"
        continue
    }

    # ── Case 2: auto-generate ────────────────────────────────────────────
    $zhTitle = Get-FM $raw "title"
    $weight  = Get-FM $raw "weight"
    $date    = Get-FM $raw "date"
    $tags    = Get-FM $raw "tags"
    $math    = Get-FM $raw "math"

    $enTitle = Translate-Title $zhTitle

    $extras = @()
    if ($tags) { $extras += "tags: $tags" }
    if ($math) { $extras += "math: $math" }

    $fm = Build-FM $enTitle $weight $date $extras

    if ($file.Name -eq "_index.md") {
        # Section index without explicit content: minimal stub
        $body = $fm + @"

{{< callout type="info" >}}
This section is being translated into English. Switch to Chinese (中文) using the language toggle in the top navigation to view full content.
{{< /callout >}}
"@
    } else {
        # Article page: stub with translation notice
        $body = $fm + @"

{{< callout type="info" >}}
This article has not been translated to English yet. Please use the language toggle in the top navigation bar to switch to Chinese and read the full content.
{{< /callout >}}
"@
    }

    [System.IO.File]::WriteAllText($enPath, $body, $utf8NoBom)
    $created++
}

Write-Host ""
Write-Host "Done. Created: $created  |  Skipped (already existed): $skipped"
