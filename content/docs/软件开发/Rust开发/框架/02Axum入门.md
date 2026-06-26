---
title: "Axum 入门"
weight: 20
date: 2026-06-16
tags: ["Rust", "Axum", "Web框架", "Tokio"]
---

这篇讲 Axum——Tokio 团队出品的 Web 框架，以简洁、模块化、利用 Rust 类型系统见长。与 Actix-web 的 Actor 体系不同，Axum 完全基于 Tower 和 Tokio 生态。

## Axum 是什么

Axum 由 Tokio 团队开发，主打：

- **基于 Tower**：复用 Tower 的中间件生态（限流、超时、重试……）
- **类型安全的提取器（Extractor）**：请求参数通过类型安全的 extractor 自动解析
- **无宏**：不需要 `#[actix_web::main]` 这样的宏（Rust 2024 的 `async fn main` 已足够）
- **轻量模块化**：只做路由，不捆绑 ORM/Session/模板——需要什么加什么

{{< callout type="info" >}}
Axum 和 Actix-web 是 Rust Web 框架的双雄。Actix-web 性能和生态更成熟，Axum 设计更现代、更类型安全。两者没有绝对好坏，看团队偏好。
{{< /callout >}}

## 安装与 Hello World

```toml
[dependencies]
axum = "0.8"
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
```

```rust
use axum::{routing::get, Router, response::IntoResponse};
use std::net::SocketAddr;

async fn index() -> impl IntoResponse {
    "Hello, Axum!"
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(index));

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    println!("listening on {}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

## 路由与提取器

Axum 使用提取器（Extractor）从请求中提取数据——类型告诉你它在提取什么：

```rust
use axum::{
    extract::{Path, Query, Json},
    response::Json as JsonResponse,
};
use serde::{Deserialize, Serialize};

// 路径参数
async fn get_user(Path(id): Path<u32>) -> String {
    format!("用户 ID: {}", id)
}

// 查询参数
#[derive(Deserialize)]
struct SearchParams {
    q: String,
    page: Option<u32>,
}

async fn search(Query(params): Query<SearchParams>) -> String {
    format!("搜索: {}, 页码: {:?}", params.q, params.page)
}

// JSON body + 返回 JSON
#[derive(Debug, Serialize, Deserialize)]
struct CreateUser {
    name: String,
    email: String,
}

async fn create_user(
    Json(payload): Json<CreateUser>,
) -> JsonResponse<CreateUser> {
    println!("创建用户: {:?}", payload);
    JsonResponse(payload)
}
```

## 共享状态

```rust
use axum::extract::State;
use std::sync::{Arc, Mutex};
use std::collections::HashMap;

#[derive(Clone)]
struct AppState {
    db: Arc<Mutex<HashMap<u32, String>>>,
}

async fn list_users(State(state): State<AppState>) -> String {
    let db = state.db.lock().unwrap();
    format!("{:?}", *db)
}

async fn add_user(
    State(state): State<AppState>,
    Json(user): Json<CreateUser>,
) -> String {
    let mut db = state.db.lock().unwrap();
    db.insert(1, user.name.clone());
    format!("添加了用户: {}", user.name)
}

#[tokio::main]
async fn main() {
    let state = AppState {
        db: Arc::new(Mutex::new(HashMap::new())),
    };

    let app = Router::new()
        .route("/users", axum::routing::get(list_users))
        .route("/users", axum::routing::post(add_user))
        .with_state(state);
    // ...
}
```

## 中间件（Tower 生态）

Axum 复用 Tower 中间件，任何实现了 `tower::Layer` 的东西都可以用作 Axum 中间件：

```rust
use tower::limit::ConcurrencyLimitLayer;
use tower_http::cors::{CorsLayer, Any};
use tower_http::trace::TraceLayer;

let app = Router::new()
    .route("/", get(index))
    .layer(CorsLayer::permissive())      // CORS
    .layer(ConcurrencyLimitLayer::new(64))  // 并发限制
    .layer(TraceLayer::new_for_http());     // 请求追踪日志
```

## Axum vs Actix-web

| 方面 | Axum | Actix-web |
| --- | --- | --- |
| 运行时 | Tokio | Tokio（内部自带） |
| 中间件生态 | Tower（复用） | 自有中间件 |
| 类型安全性 | 极强（提取器） | 强 |
| 宏使用 | 很少 | `#[actix_web::main]` 等 |
| 性能 | 非常好 | 极致 |
| 学习曲线 | 平缓 | 中等 |
| 适合 | 新项目、Tokio 生态用户 | 高性能 API、已有 Actix 存量 |

## 一句话小结

Axum 的类型安全提取器让 API 定义即文档，Tower 生态让中间件复用零成本。如果你已经在用 Tokio，Axum 是自然之选。前一篇文章介绍了 [Actix-web](../01Actix-web入门/)。

## 练习

用 Axum 实现以下 API：
- `GET /api/version` 返回 `{"version": "1.0.0"}`
- `GET /api/greet?name=Rust` 返回 `{"message": "Hello, Rust!"}`

{{< details title="参考答案" >}}
```rust
use axum::{
    extract::Query,
    response::Json,
    routing::get,
    Router,
};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;

#[derive(Serialize)]
struct VersionResponse {
    version: String,
}

async fn version() -> Json<VersionResponse> {
    Json(VersionResponse {
        version: "1.0.0".into(),
    })
}

#[derive(Deserialize)]
struct GreetParams {
    name: Option<String>,
}

#[derive(Serialize)]
struct GreetResponse {
    message: String,
}

async fn greet(Query(params): Query<GreetParams>) -> Json<GreetResponse> {
    let name = params.name.unwrap_or_else(|| "guest".into());
    Json(GreetResponse {
        message: format!("Hello, {}!", name),
    })
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/api/version", get(version))
        .route("/api/greet", get(greet));

    let addr = SocketAddr::from(([127, 0, 0, 1], 3000));
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```
{{< /details >}}
