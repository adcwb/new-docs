#!/usr/bin/env python3
"""
generate-en.py — Creates .en.md stub files for all untranslated content.

Usage:
    cd d:\\Projects\\Docs\\new-docs
    python scripts/generate-en.py

For each *.md file (excluding *.en.md) that has no .en.md counterpart:
- _index.md  → _index.en.md (section stub with translation notice)
- article.md → article.en.md (article stub with translation notice)

Files that already have a .en.md counterpart are skipped.
Run after manually placing explicit _index.en.md files in key directories.
"""

import os
import re
import sys

DOCS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "content", "docs")

# Chinese → English title translations
TITLE_MAP = {
    "软件开发": "Software Development",
    "系统管理": "System Administration",
    "网络技术": "Networking",
    "人工智能": "Artificial Intelligence",
    "数据库": "Databases",
    "数据分析": "Data Analysis",
    "金融相关": "Finance & Trading",
    "Markdown语法": "Markdown Syntax",
    "Python开发": "Python Development",
    "Golang开发": "Golang Development",
    "Rust开发": "Rust Development",
    "PHP开发": "PHP Development",
    "Web开发": "Web Development",
    "Linux系统": "Linux Systems",
    "云原生": "Cloud Native",
    "安全": "Security",
    "机器学习基础": "Machine Learning",
    "深度学习基础": "Deep Learning",
    "大模型应用": "LLM Applications",
    "MySql数据库": "MySQL",
    "Python基础": "Python Fundamentals",
    "Python框架": "Python Frameworks",
    "Python测试": "Python Testing",
    "Python爬虫": "Web Scraping",
    "Python网络编程": "Python Networking",
    "py小工具": "Python Utilities",
    "drf课件(新版)": "DRF Course",
    "基础": "Fundamentals",
    "框架": "Frameworks",
    "插件": "Plugins",
    "模型": "Models & Patterns",
    "进阶": "Advanced",
    "业务数据分析": "Business Analytics",
    "办公自动化": "Office Automation",
    "Kali渗透": "Kali Pentesting",
    "Web安全": "Web Security",
    "WiFi安全": "WiFi Security",
    "漏洞挖掘": "Vulnerability Research",
    "系统服务": "System Services",
    "常用命令": "Common Commands",
    "PHP基础": "PHP Fundamentals",
    "PHP数据库": "PHP & Databases",
    "PHP框架": "PHP Frameworks",
    "概览": "Overview",
}


def translate_title(zh: str) -> str:
    zh = zh.strip().strip('"\'')
    if zh in TITLE_MAP:
        return TITLE_MAP[zh]
    result = zh
    for k, v in TITLE_MAP.items():
        result = result.replace(k, v)
    return result


def extract_fm_value(content: str, key: str):
    m = re.search(rf"^{key}:\s*[\"']?(.+?)[\"']?\s*$", content, re.MULTILINE)
    return m.group(1).strip().strip('"\'') if m else None


def build_stub(src_path: str, is_index: bool) -> str:
    with open(src_path, encoding="utf-8") as f:
        raw = f.read()

    title  = extract_fm_value(raw, "title") or "Untitled"
    weight = extract_fm_value(raw, "weight")
    date   = extract_fm_value(raw, "date")
    tags   = extract_fm_value(raw, "tags")
    math   = extract_fm_value(raw, "math")

    en_title = translate_title(title)

    fm_lines = ['---', f'title: "{en_title}"']
    if weight:
        fm_lines.append(f"weight: {weight}")
    if date:
        fm_lines.append(f"date: {date}")
    if tags:
        fm_lines.append(f"tags: {tags}")
    if math:
        fm_lines.append(f"math: {math}")
    fm_lines.append("---")
    fm = "\n".join(fm_lines) + "\n"

    notice = (
        "\n{{< callout type=\"info\" >}}\n"
        "This section is being translated. Switch to Chinese (中文) using the language toggle to view the full content.\n"
        "{{< /callout >}}\n"
        if is_index else
        "\n{{< callout type=\"info\" >}}\n"
        "This article has not been translated to English yet. Use the language toggle in the top navigation bar to switch to Chinese and read the full content.\n"
        "{{< /callout >}}\n"
    )

    return fm + notice


def main():
    created = 0
    skipped = 0

    for root, dirs, files in os.walk(DOCS_DIR):
        dirs.sort()
        for fname in sorted(files):
            if not fname.endswith(".md"):
                continue
            if fname.endswith(".en.md"):
                continue

            src = os.path.join(root, fname)
            is_index = fname == "_index.md"

            if is_index:
                en_path = os.path.join(root, "_index.en.md")
            else:
                base = fname[:-3]  # strip .md
                en_path = os.path.join(root, base + ".en.md")

            if os.path.exists(en_path):
                skipped += 1
                continue

            content = build_stub(src, is_index)
            with open(en_path, "w", encoding="utf-8") as f:
                f.write(content)
            created += 1
            rel = os.path.relpath(en_path, DOCS_DIR)
            print(f"  created  {rel}")

    print(f"\nDone. Created: {created}  |  Skipped (already existed): {skipped}")


if __name__ == "__main__":
    main()
