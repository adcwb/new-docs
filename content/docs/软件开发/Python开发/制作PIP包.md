---
title: "制作PIP包"
weight: 90
date: 2026-06-23
---

## 制作PIP包

### 简介

本教程将引导您完成如何打包一个简单的 Python 项目。它将向您展示如何添加必要的文件和结构来创建包、如何构建包以及如何将其上传到 Python 包索引。



### 依赖

```bash
# 安装并更新pip包
# Unix/MacOS/Linux
python3 -m pip install --upgrade pip

# Windows
py -m pip install --upgrade pip

```



### 创建项目

本教程使用一个名为`example_package`. 我们建议在打包您自己的项目之前，按原样使用此项目来遵循本教程。

在本地创建以下文件结构：

```python
mypackage/
    └── src/
        ├── __init__.py
        └── example.py

# example.py 随便写一些内容进去，此处__init__.py为空

def add_one(number: int) -> int:
    """
    number + 1
    :param number: type int
    :return: type int
    """
    return number + 1


def add_two(number1: str, number2: str) -> str:
    """
    number1 + number2
    :param number1: type str
    :param number2: type str
    :return: type str
    """
    return number1 + number2

```



### 创建包文件

现在将添加用于准备项目以进行分发的文件。完成后，项目结构将如下所示：

```bash
mypackage/
    ├── LICENSE
    ├── pyproject.toml
    ├── README.md
    ├── setup.cfg
    ├── src/
        ├── __init__.py
        └── example.py
    └── tests/
```



### 测试目录

`tests/`是测试文件的占位符。暂时将其留空即可。



### 构建项目配置文件

`pyproject.toml`告诉构建工具（如[pip](https://packaging.python.org/en/latest/key_projects/#pip)和[build](https://packaging.python.org/en/latest/key_projects/#build)）构建项目所需的内容。

在此项目中，假设需要使用`setuptools` 和`wheel` 

打开`pyproject.toml`并输入以下内容：

```bash
[build-system]
requires = [
    "setuptools>=42",
    "wheel"
]
build-backend = "setuptools.build_meta"

```

`build-system.requires`给出构建包所需的包列表。在此处列出某些内容*只会*使其在构建期间可用，而不是在安装后可用。

`build-system.build-backend`是将用于执行构建的 Python 对象的名称。如果您要使用不同的构建系统，例如 [flit](https://packaging.python.org/en/latest/key_projects/#flit)或[poetry](https://packaging.python.org/en/latest/key_projects/#poetry)，它们会放在这里，并且配置细节将与下面描述的[setuptools](https://packaging.python.org/en/latest/key_projects/#setuptools)配置完全不同。

### 元数据配置

元数据有两种类型：静态和动态。

- 静态元数据（`setup.cfg`）：保证每次都相同。这更简单，更易于阅读，并且避免了许多常见错误，例如编码错误。
- 动态元数据 ( `setup.py`)：可能是不确定的。任何在安装时动态或确定的项目，以及扩展模块或 `setuptools` 扩展，都需要进入`setup.py`.

`setup.cfg`应首选静态元数据 ( )。动态元数据 ( `setup.py`) 应仅在绝对必要时用作逃生舱口。`setup.py`以前是必需的，但可以在较新版本的 `setuptools` 和 `pip` 中省略。

#### setup.cfg

`setup.cfg`是[`setuptools`](https://packaging.python.org/en/latest/key_projects/#setuptools)的配置文件。它告诉 `setuptools` 您的包（例如名称和版本）以及要包含的代码文件。最终，这种配置中的大部分可能会迁移到`pyproject.toml`.

打开`setup.cfg`并输入以下内容。更改`name` 以包含您的用户名；这可确保您拥有唯一的包名称，并且您的包不会与其他人按照本教程上传的包冲突。

```bash
[metadata]
name = example-pkg-adcwb
version = 0.0.1
author = adcwb
author_email = adcwbf@gmail.com
description = A small example package
long_description = file: README.md
long_description_content_type = text/markdown
url = https://github.com/adcwb/docs
project_urls =
    Bug Tracker = https://github.com/adcwb/docs/issues
classifiers =
    Programming Language :: Python :: 3
    License :: OSI Approved :: MIT License
    Operating System :: OS Independent

[options]
package_dir =
    = src
packages = find:
python_requires = >=3.6

[options.packages.find]
where = src
```

这里 支持[多种元数据和选项](https://setuptools.readthedocs.io/en/latest/userguide/declarative_config.html)。这是[configparser](https://docs.python.org/3/library/configparser.html) 格式；不要在值周围加上引号。这个示例包使用了一组相对最少的`metadata`：

- `name`是您的包的*分发名称*。这可以是任何名称，只要它只包含字母、数字`_`、 和`-`。它也不能在 pypi.org 上使用。**请务必使用您的用户名进行更新，** 因为这样可以确保您不会尝试上传与已经存在的同名的包。
- `version`是包版本。看[**PEP 440**](https://www.python.org/dev/peps/pep-0440)有关版本的更多详细信息。您可以使用`file:`or`attr:`指令从文件或包属性中读取。
- `author`并`author_email`用于标识包的作者。
- `description` 是一个简短的、一句话的包摘要。
- `long_description`是包的详细说明。这显示在 Python 包索引的包详细信息页面上。在这种情况下，`README.md`使用`file:`指令从（这是一种常见模式）加载长描述。
- `long_description_content_type`告诉索引长描述使用什么类型的标记。在这种情况下，它是 Markdown。
- `url`是项目主页的 URL。对于许多项目，这只是指向 GitHub、GitLab、Bitbucket 或类似代码托管服务的链接。
- `project_urls`允许您列出要在 PyPI 上显示的任意数量的额外链接。通常，这可能是文档、问题跟踪器等。
- `classifiers`提供 index 和[pip](https://packaging.python.org/en/latest/key_projects/#pip)一些关于你的包的额外元数据。在这种情况下，该包仅与 Python 3 兼容，在 MIT 许可下获得许可，并且独立于操作系统。您应该始终至少包括您的包适用于哪个 Python 版本、您的包在哪个许可证下可用，以及您的包将在哪些操作系统上运行。有关分类器的完整列表，请参阅 https://pypi.org/classifiers/。

在该`options`类别中，我们有 setuptools 本身的控件：

- `package_dir`是包名和目录的映射。一个空的包名代表“根包”——项目中包含包的所有 Python 源文件的`src`目录——所以在这种情况下，该目录被指定为根包。
- `packages`是应包含在[分发包](https://packaging.python.org/en/latest/glossary/#term-Distribution-Package)中的所有 Python[导入包](https://packaging.python.org/en/latest/glossary/#term-Import-Package)的列表。我们可以使用指令自动发现所有包和子包并指定 要使用的包，而不是手动列出每个包。在这种情况下，包列表将是唯一存在的包。`find:``options.packages.find``package_dir``example_package`
- `python_requires`给出项目支持的 Python 版本。像[pip](https://packaging.python.org/en/latest/key_projects/#pip)这样的安装程序会回顾旧版本的包，直到找到一个与 Python 版本匹配的包。

除了这里提到的还有很多。有关更多详细信息，请参阅 [打包和分发项目](https://packaging.python.org/en/latest/guides/distributing-packages-using-setuptools/)。



#### setup.py

```python
import setuptools

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setuptools.setup(
    name="example-pkg-YOUR-USERNAME-HERE",
    version="0.0.1",
    author="Example Author",
    author_email="author@example.com",
    description="A small example package",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/pypa/sampleproject",
    project_urls={
        "Bug Tracker": "https://github.com/pypa/sampleproject/issues",
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    package_dir={"": "src"},
    packages=setuptools.find_packages(where="src"),
    python_requires=">=3.6",
)
```

`setup()`需要几个参数。这个示例包使用了一个相对最小的集合：

- `name`是您的包的*分发名称*。这可以是任何名称，只要它只包含字母、数字`_`、 和`-`。它也不能在 pypi.org 上使用。**请务必使用您的用户名进行更新，** 因为这样可以确保您不会尝试上传与已经存在的同名的包。
- `version`是包版本。看[**PEP 440**](https://www.python.org/dev/peps/pep-0440)有关版本的更多详细信息。
- `author`并`author_email`用于标识包的作者。
- `description` 是一个简短的、一句话的包摘要。
- `long_description`是包的详细说明。这显示在 Python 包索引的包详细信息页面上。在这种情况下，长描述是从 加载的`README.md`，这是一种常见的模式。
- `long_description_content_type`告诉索引长描述使用什么类型的标记。在这种情况下，它是 Markdown。
- `url`是项目主页的 URL。对于许多项目，这只是指向 GitHub、GitLab、Bitbucket 或类似代码托管服务的链接。
- `project_urls`允许您列出要在 PyPI 上显示的任意数量的额外链接。通常，这可能是文档、问题跟踪器等。
- `classifiers`提供 index 和[pip](https://packaging.python.org/en/latest/key_projects/#pip)一些关于你的包的额外元数据。在这种情况下，该包仅与 Python 3 兼容，在 MIT 许可下获得许可，并且独立于操作系统。您应该始终至少包括您的包适用于哪个 Python 版本、您的包在哪个许可证下可用，以及您的包将在哪些操作系统上运行。有关分类器的完整列表，请参阅 https://pypi.org/classifiers/。
- `package_dir`是一个字典，其中键的包名称和值的目录。一个空的包名代表“根包”——项目中包含包的所有 Python 源文件的`src`目录——所以在这种情况下，该目录被指定为根包。
- `packages`是应包含在[分发包](https://packaging.python.org/en/latest/glossary/#term-Distribution-Package)中的所有 Python[导入包](https://packaging.python.org/en/latest/glossary/#term-Import-Package)的列表。无需手动列出每个包，我们可以使用它来自动发现. 在这种情况下，包列表将是唯一存在的包。`find_packages()``package_dir``example_package`
- `python_requires`给出项目支持的 Python 版本。像[pip](https://packaging.python.org/en/latest/key_projects/#pip)这样的安装程序会回顾旧版本的包，直到找到具有匹配 Python 版本的包。

除了这里提到的还有很多。有关更多详细信息，请参阅 [打包和分发项目](https://packaging.python.org/en/latest/guides/distributing-packages-using-setuptools/)。



您可能会看到一些现有项目或其他 Python 打包教程，它们`setup`从而`distutils.core`不是 从`setuptools`. 这是安装程序支持向后兼容目的的遗留方法[1](https://packaging.python.org/en/latest/tutorials/packaging-projects/#id2)，但`distutils`强烈建议不要在新项目中直接使用遗留API，因为`distutils`已弃用[**PEP 632**](https://www.python.org/dev/peps/pep-0632)，将从 Python 3.12 的标准库中删除。



### 项目说明文件

打开`README.md`并输入对于此项目的描述信息

```bash
# Example Package

This is a simple example package. You can use
[Github-flavored Markdown](https://guides.github.com/features/mastering-markdown/)
to write your content.
```

因为我们的配置加载`README.md`提供了一个 `long_description`，`README.md`当您[生成源代码分发](https://packaging.python.org/en/latest/tutorials/packaging-projects/#generating-archives)时，必须与您的代码一起包含。较新版本的[setuptools](https://packaging.python.org/en/latest/key_projects/#setuptools)将自动执行此操作。



### 创建许可文件

上传到 Python 包索引的每个包都必须包含许可证，这一点很重要。这会告诉安装您的软件包的用户他们可以使用您的软件包的条款。有关选择许可证的帮助，请参阅 https://choosealicense.com/。选择许可证后，打开 `LICENSE`并输入许可证文本。例如，如果您选择了 MIT 许可证：

```text
Copyright (c) 2022 The Python Packaging Authority

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```



### 其他文件

上面列出的文件将自动包含在您的 [源代码分发中](https://packaging.python.org/en/latest/glossary/#term-Source-Distribution-or-sdist)。如果您想明确控制[其中的](https://packaging.python.org/en/latest/guides/using-manifest-in/#using-manifest-in)内容，请参阅[使用 MANIFEST.in 在源分发中包含文件](https://packaging.python.org/en/latest/guides/using-manifest-in/#using-manifest-in)。

最终[构建的发行版](https://packaging.python.org/en/latest/glossary/#term-Built-Distribution)将在已发现或列出的 Python 包中包含 Python 文件。如果你想控制一下放在这里，如添加数据文件，请参阅 [包括数据文件](https://setuptools.pypa.io/en/latest/userguide/datafiles.html) 从[setuptools的文档](https://setuptools.pypa.io/en/latest/index.html)。



## 生成分发包

此处将刚才的项目封装成软件包，这些是上传到 Python 包索引的档案，可以通过[pip](https://packaging.python.org/en/latest/key_projects/#pip)构建

```bash
# 安装 包构建工具
# Unix/Linux/MacOS
python3 -m pip install --upgrade build

# windows
py -m pip install --upgrade build
```

如果您在安装这些文件时遇到问题，请参阅 [安装包](https://packaging.python.org/en/latest/tutorials/installing-packages/)教程。

```bash
# 在pyproject.toml文件所在的目录中执行构建命令
# Unix/Linux/MacOS
python3 -m build

# windows
py -m build

# 此命令应输出大量文本，完成后应在dist目录中生成两个文件：
dist/
    ├── example_pkg_adcwb-0.0.1-py3-none-any.whl
    └── example-pkg-adcwb-0.0.1.tar.gz

# 该tar.gz文件是一个源存档，而该 .whl文件是一个构建分布。较新的 pip版本优先安装已构建的发行版，但如果需要，将回退到源存档。您应该始终上传源存档并为您的项目兼容的平台提供构建的存档。在这种情况下，我们的示例包在任何平台上都与 Python 兼容，因此只需要一个内置发行版。
```



## 上传包

最后，是时候将你的包上传到 Python 包索引了！

由于此处的项目并不是真实的项目，仅是一个提供项目，所以无需上传到真正的pip库，使用pip官方提供的测试库即可。

您需要做的第一件事是在 TestPyPI 上注册一个帐户，这是用于测试和实验的包索引的单独实例。对于像本教程这样我们不一定要上传到真实索引的东西来说，这非常有用。要注册帐户，请转到 https://test.pypi.org/account/register/并完成该页面上的步骤。在上传任何包裹之前，您还需要验证您的电子邮件地址。有关更多详细信息，请参阅[使用 TestPyPI](https://packaging.python.org/en/latest/guides/using-testpypi/)。

要安全地上传您的项目，您需要一个 PyPI [API 令牌](https://test.pypi.org/help/#apitoken)。在https://test.pypi.org/manage/account/#api-tokens创建一个 ，将“Scope”设置为“Entire account”。**在复制并保存令牌之前不要关闭页面 - 您将不会再看到该令牌。**


### 使用twine上传包

[Twine](https://twine.readthedocs.io/en/latest/) 是一个用于将Python 包[发布](https://packaging.python.org/tutorials/packaging-projects/)到[PyPI](https://pypi.org/)和其他 [存储库](https://packaging.python.org/glossary/#term-Package-Index)的实用程序。它为新[项目](https://packaging.python.org/glossary/#term-Project)和现有 [项目](https://packaging.python.org/glossary/#term-Project)提供独立于构建系统的源和二进制[分发工件的](https://packaging.python.org/glossary/#term-Distribution-Package)上传。

- 特点

    - 已验证的 HTTPS 连接
    - 上传不需要执行 `setup.py`
    - 上传已经创建的文件，允许在发布前测试发行版
    - 支持上传任何包装格式（包括[wheels](https://packaging.python.org/glossary/#term-Wheel)）

- 安装

    ```bash
    pip install twine
    ```

- 使用

    1. 以正常方式创建一些分布：

        ```text
        python -m build
        ```

    2. 上传到[Test PyPI](https://packaging.python.org/guides/using-testpypi/)并验证一切是否正确：

        ```text
        twine upload -r testpypi dist/*
        ```

        Twine 将提示您输入用户名和密码。

    3. 上传到[PyPI](https://pypi.org/)：

        ```text
        twine upload dist/*
        ```

    4. 完毕！

    5. 

系统将提示您输入用户名和密码。对于用户名，使用`__token__`. 对于密码，使用令牌值，包括`pypi-`前缀。

命令完成后，您应该会看到类似于以下内容的输出：

```bash
Uploading distributions to https://test.pypi.org/legacy/
Enter your username: __token__
Enter your password: 
Uploading example_pkg_adcwb-0.0.1-py3-none-any.whl
100%|██████████| 5.52k/5.52k [00:01<00:00, 2.98kB/s]
Uploading example-pkg-adcwb-0.0.1.tar.gz
100%|██████████| 5.27k/5.27k [00:01<00:00, 3.12kB/s]

View at:
	https://test.pypi.org/project/example-pkg-adcwb/0.0.1/

```

上传后，您的包应该可以在 TestPyPI 上查看，可以访问上面给定的链接进行查看



## 安装新上传的包

您可以使用[pip](https://packaging.python.org/en/latest/key_projects/#pip)安装您的软件包并验证它是否有效。创建一个[虚拟环境](https://packaging.python.org/en/latest/tutorials/installing-packages/#creating-and-using-virtual-environments) 并从 TestPyPI 安装你的包：

```bash
# python3 -m pip install --index-url https://test.pypi.org/simple/ --no-deps example-pkg-adcwb

(test_project) $ python3 -m pip install --index-url https://test.pypi.org/simple/ --no-deps example-pkg-adcwb
Looking in indexes: https://test.pypi.org/simple/
Collecting example-pkg-adcwb==0.0.1
  Downloading https://test-files.pythonhosted.org/packages/5a/e5/57223588cfceed026b6d20a9d826e060e83ed06177f505e1ef9a56b2f3f4/example_pkg_adcwb-0.0.1-py3-none-any.whl (2.2 kB)
Installing collected packages: example-pkg-adcwb
Successfully installed example-pkg-adcwb-0.0.1

```

此示例使用`--index-url`标志来指定 TestPyPI 而不是 live PyPI。此外，它指定`--no-deps`. 由于 TestPyPI 没有与实时 PyPI 相同的包，因此尝试安装依赖项可能会失败或安装意外的东西。虽然我们的示例包没有任何依赖项，但在使用 TestPyPI 时避免安装依赖项是一个好习惯。

您可以通过导入包来测试它是否安装正确。确保您仍在虚拟环境中，然后运行 Python：

```python
>>> from example_package import example
>>> example.add_one(2)
3
```



请记住，本教程向您展示了如何将包上传到 Test PyPI，它不是永久存储。测试系统偶尔会删除包和帐户。最好使用 TestPyPI 进行像本教程这样的测试和实验。

当您准备好将真实包上传到 Python 包索引时，您可以执行与本教程中所做的大致相同的操作，但有以下重要区别：

- 为您的包裹选择一个令人难忘且独特的名称。您不必像在教程中那样附加您的用户名。
- 在[https://pypi.org](https://pypi.org/)上注册一个帐户- 请注意，这是两个独立的服务器，并且来自测试服务器的登录详细信息不与主服务器共享。
- 使用上传你的包，并输入您的凭据为你真正的PyPI注册的账号。现在您正在生产环境中上传包，您无需指定; 默认情况下，该包将上传到https://pypi.org/。`twine upload dist/*``--repository`
- 使用.从真正的 PyPI 安装你的包。`python3 -m pip install [your-package]`

此时，如果您想了解更多关于打包 Python 库的信息，您可以执行以下操作：

- 在[打包和分发项目中](https://packaging.python.org/en/latest/guides/distributing-packages-using-setuptools/)阅读有关使用[setuptools](https://packaging.python.org/en/latest/key_projects/#setuptools)打包库的 更多信息。
- 阅读有关[打包二进制扩展的信息](https://packaging.python.org/en/latest/guides/packaging-binary-extensions/)。
- 考虑替代[的setuptools](https://packaging.python.org/en/latest/key_projects/#setuptools)如[迁徙](https://packaging.python.org/en/latest/key_projects/#flit)，[孵化](https://packaging.python.org/en/latest/key_projects/#hatch)和[诗](https://packaging.python.org/en/latest/key_projects/#poetry)。

