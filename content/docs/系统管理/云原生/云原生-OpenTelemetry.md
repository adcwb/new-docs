---
title: "云原生-OpenTelemetry"
weight: 40
date: 2026-06-05
---

## OpenTelemetry使用指南



### 什么是OpenTelemetry

OpenTelemetry 是一个[可观测性](https://opentelemetry.io/docs/concepts/observability-primer/#what-is-observability)框架和工具包， 旨在创建和管理遥测数据，如[链路](https://opentelemetry.io/docs/concepts/signals/traces/)、 [指标](https://opentelemetry.io/docs/concepts/signals/metrics/)和[日志](https://opentelemetry.io/docs/concepts/signals/logs/)。 重要的是，OpenTelemetry 是供应商和工具无关的，这意味着它可以与各种可观测性后端一起使用， 包括 [Jaeger](https://www.jaegertracing.io/) 和 [Prometheus](https://prometheus.io/) 这类开源工具以及商业化产品。

OpenTelemetry 不是像 Jaeger、Prometheus 或其他商业供应商那样的可观测性后端。 OpenTelemetry 专注于遥测数据的生成、采集、管理和导出。 OpenTelemetry 的一个主要目标是， 无论应用程序或系统采用何种编程语言、基础设施或运行时环境，你都可以轻松地将其仪表化。 重要的是，遥测数据的存储和可视化是有意留给其他工具处理的。



### 什么是可观测性

[可观测性](https://opentelemetry.io/docs/concepts/observability-primer/#what-is-observability)是通过检查系统输出来理解系统内部状态的能力。 在软件的背景下，这意味着能够通过检查遥测数据（包括链路、指标和日志）来理解系统的内部状态。

要使系统可观测，必须对其进行仪表化。也就是说，代码必须发出链路、指标或日志。 然后，仪表化的数据必须发送到可观测性后端。



### 主要的 OpenTelemetry 组件

OpenTelemetry 包括以下主要组件：

- 适用于所有组件的[规范](https://opentelemetry.io/docs/specs/otel)
- 定义遥测数据形状的标准[协议](https://opentelemetry.io/docs/specs/otlp/)
- 为常见遥测数据类型定义标准命名方案的[语义约定](https://opentelemetry.io/docs/specs/semconv/)
- 定义如何生成遥测数据的 API
- 实现规范、API 和遥测数据导出的[语言 SDK](https://opentelemetry.io/docs/languages)
- 实现常见库和框架的仪表化的[库生态系统](https://opentelemetry.io/ecosystem/registry)
- 可自动生成遥测数据的自动仪表化组件，无需更改代码
- [OpenTelemetry Collector](https://opentelemetry.io/docs/collector)：接收、处理和导出遥测数据的代理
- 各种其他工具， 如[用于 Kubernetes 的 OpenTelemetry Operator](https://opentelemetry.io/docs/kubernetes/operator/)、 [OpenTelemetry Helm Charts](https://opentelemetry.io/docs/kubernetes/helm/) 和 [FaaS 的社区资产](https://opentelemetry.io/docs/faas/)

OpenTelemetry 广泛应用于许多已集成 OpenTelemetry 提供默认可观测性的[库、服务和应用](https://opentelemetry.io/ecosystem/integrations/)。

OpenTelemetry 得到众多[供应商](https://opentelemetry.io/ecosystem/vendors/)的支持，其中许多为 OpenTelemetry 提供商业支持并直接为此项目做贡献。



### 可扩展性

OpenTelemetry 被设计为可扩展的。一些扩展 OpenTelemetry 的例子包括：

- 向 OpenTelemetry Collector 添加接收器以支持来自自定义源的遥测数据
- 将自定义仪表化库加载到 SDK 中
- 创建适用于特定用例的 SDK 或 Collector 的[分发](https://opentelemetry.io/docs/concepts/distributions/)
- 为尚不支持 OpenTelemetry 协议（OTLP）的自定义后端创建新的导出器
- 为非标准上下文传播格式创建自定义传播器

尽管大多数用户可能不需要扩展 OpenTelemetry，但此项目几乎每个层面都可以实现扩展。



## OpenTelemetry插桩方式

### 自动插桩

运行以下命令以安装相应的软件包。

```sh
pip install opentelemetry-distro opentelemetry-exporter-otlp
opentelemetry-bootstrap -a install
```

该软件包将安装 API、SDK 和 and 工具。`opentelemetry-distro``opentelemetry-bootstrap``opentelemetry-instrument`

该命令将读取 软件包，并将 这些包的相应插桩库（如果适用）。为 例如，如果您已经安装了该软件包，则运行 Will Install。OpenTelemetry Python 代理 将在运行时使用 monkey patching 来修改这些库中的函数。`opentelemetry-bootstrap -a install``site-packages``flask``opentelemetry-bootstrap -a install``opentelemetry-instrumentation-flask`



配置代理

```sh
# 命令行
opentelemetry-instrument \
    --traces_exporter console,otlp \
    --metrics_exporter console \
    --service_name your-service-name \
    --exporter_otlp_endpoint 0.0.0.0:4317 \
    python myapp.py

# 环境变量
```



### 手动插桩



### Django项目



1、安装相应依赖包

- **opentelemetry-instrumentation-django**：用于自动追踪 Django 应用中的请求。

- **opentelemetry-sdk**：OpenTelemetry SDK 的核心库。

- **opentelemetry-exporter-prometheus**：用于将追踪数据导出到 Prometheus。

```python
pip install opentelemetry-instrumentation-django 
pip install opentelemetry-sdk
pip install opentelemetry-exporter-prometheus 
pip install opentelemetry-exporter-otlp
```

2、配置 OpenTelemetry

在Django项目的 `settings.py` 文件中添加以下配置

```python
```

