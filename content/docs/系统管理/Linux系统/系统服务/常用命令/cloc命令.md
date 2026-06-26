---
title: "cloc命令"
weight: 50
date: 2026-06-05
---

## 一、工具简介

`cloc` 命令是一个开源的代码统计工具，全称是 `Count Lines of Code`。 用于统计源代码文件中的：

- **代码行数 (code)**
- **注释行数 (comment)**
- **空白行数 (blank)**

支持 **190+ 种语言**，包括 C/C++、Go、Python、Java、JavaScript、HTML、SQL、Shell 等。

> 📦 GitHub 项目地址：
>  https://github.com/AlDanial/cloc





## 二、安装方式

### 1️⃣ Linux / macOS

```bash
sudo apt install cloc    # Ubuntu/Debian
brew install cloc        # macOS (Homebrew)
```

### 2️⃣ Windows

- 直接下载可执行文件：https://github.com/AlDanial/cloc/releases

- 或使用 Perl 版本：

  ```text
  perl cloc-*.pl .
  ```





## 三、基本用法

| 命令                            | 说明                           |
| ------------------------------- | ------------------------------ |
| `cloc .`                        | 统计当前目录下的所有源代码文件 |
| `cloc <path>`                   | 统计指定文件或目录             |
| `cloc *.py`                     | 统计所有 Python 文件           |
| `cloc --exclude-dir=dist,build` | 排除某些目录                   |
| `cloc --exclude-ext=html,css`   | 排除特定后缀文件               |
| `cloc --exclude-lang=HTML,JSON` | 排除某些语言类型               |

------

## 四、常用选项详解

### ✅ 输出格式控制

| 选项                         | 说明                                              |
| ---------------------------- | ------------------------------------------------- |
| `--by-file`                  | 按文件统计                                        |
| `--by-file-by-lang`          | 同时按语言和文件统计                              |
| `--csv` / `--json` / `--xml` | 输出为机器可读格式（适合导入到 Excel 或系统分析） |
| `--report-file=output.txt`   | 将结果输出到文件                                  |

### ✅ 统计差异与 Git 集成

| 命令                              | 功能                               |
| --------------------------------- | ---------------------------------- |
| `cloc --diff dir1 dir2`           | 对比两个目录的代码差异             |
| `cloc --count-and-diff dir1 dir2` | 分别统计两者后计算差值             |
| `cloc --git HEAD~1`               | 统计最近一次提交与上一次提交的差异 |
| `cloc --git master..dev`          | 统计两个分支之间的代码行数变化     |

> 💡 示例：
>
> ```
> cloc --git master..feature/new-ui
> ```
>
> 输出结果会显示哪些语言新增或减少了多少行代码。

------

## 五、进阶用法示例

### 1️⃣ 统计多语言项目并导出 CSV 报告

```text
cloc . --exclude-dir=node_modules,dist --csv --report-file=cloc_report.csv
```

### 2️⃣ 按语言统计各文件平均行数

```text
cloc --by-file-by-lang . | sort -k2 -nr
```

### 3️⃣ 统计指定语言（如 Go、Python）

```text
cloc . --include-lang=Go,Python
```

### 4️⃣ 比较两个 Git 提交

```bash
cloc --git 'HEAD~5..HEAD'
```

### 5️⃣ 与其他工具结合（例如 CI/CD）

在 Jenkins 或 GitHub Actions 中可用如下命令生成代码统计报告：

```text
cloc . --json --out=cloc.json
```

然后上传为制品或推送到仪表盘系统（如 SonarQube、DataDog）。

------

## 六、输出结果说明

执行后典型输出如下：

```text
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Go                               32            820            360           4800
Python                           10            210            180           1450
JavaScript                        5            100             70            850
-------------------------------------------------------------------------------
SUM:                             47           1130            610           7100
-------------------------------------------------------------------------------
```

| 列名      | 含义     |
| --------- | -------- |
| `files`   | 文件数量 |
| `blank`   | 空白行数 |
| `comment` | 注释行数 |
| `code`    | 代码行数 |

------

## 七、性能与精确度优化建议

- 使用 `--skip-uniqueness` 可加快大项目统计速度。

- 使用 `--read-binary-files` 可忽略二进制检测，提升性能（适用于特定情况）。

- 对大型 monorepo 可使用 `--match-f="regex"` 限制扫描路径。

- 若项目在容器中运行，可直接：

  ```bash
  docker run --rm -v $PWD:/code aldanial/cloc /code
  ```

------

## 八、与其他统计工具比较

| 工具          | 特点                                               |
| ------------- | -------------------------------------------------- |
| **cloc**      | 多语言支持最全面、输出格式丰富、轻量级、命令行友好 |
| **tokei**     | 用 Rust 编写，性能极高（推荐用于超大仓库）         |
| **scc**       | Go 实现，比 cloc 快 10x 左右，支持类似参数         |
| **sloccount** | 较旧工具，不再维护                                 |

------

## 九、实践建议（适合团队）

1. **集成到 CI 流程中**，定期生成代码增长报告。
2. **与 Git 提交记录关联**，分析代码增长趋势。
3. **通过 JSON 输出结合 Grafana/Prometheus** 做代码统计可视化。
4. **作为审计工具**，用于统计第三方依赖、验证代码资产规模。