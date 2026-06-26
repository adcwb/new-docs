---
title: "Actix-web 入门"
weight: 10
date: 2026-06-16
tags: ["Rust", "Actix-web", "Web框架"]
---

这篇讲 Actix-web——Rust 生态中目前最快、最成熟的 Web 框架之一。基于 Actor 模型，它在 TechEmpower 基准测试中长期霸榜。

## Actix-web 是什么

Actix-web 是一个轻量、高性能的异步 Web 框架。核心特点：

- 基于 Actor 模型（`actix` crate），每个请求由独立的 actor 处理
- 异步 I/O（基于 `tokio` 运行时）
- 强类型路由和提取器
- 内置中间件系统（日志、压缩、CORS、Session）
- 极高的吞吐量和极低的延迟

{{< callout type="info" >}}
Actix-web 是 Rust Web 框架中的性能怪兽。如果你从 Go 的 Gin/Echo 或 Python 的 FastAPI 转过来，Actix-web 的性能会显著提升。
{{< /callout >}}

## 安装与第一个应用

`Cargo.toml`：

```toml
[dependencies]
actix-web = "4"
serde = { version = "1", features = ["derive"] }
tokio = { version = "1", features = ["full"] }
```

第一个 Actix-web 应用：

```rust
use actix_web::{web, App, HttpResponse, HttpServer, Responder};

async fn index() -> impl Responder {
    HttpResponse::Ok().body("Hello, Actix-web!")
}

async fn greet(name: web::Path<String>) -> impl Responder {
    HttpResponse::Ok().body(format!("Hello, {}!", name))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(index))
            .route("/greet/{name}", web::get().to(greet))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
```

运行：

```bash
cargo run
# 访问 http://localhost:8080/
# 访问 http://localhost:8080/greet/Rust
```

## JSON 处理

用 `serde` 序列化和反序列化 JSON：

```rust
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
struct User {
    name: String,
    age: u8,
}

// 接收 JSON 并返回 JSON
async fn create_user(user: web::Json<User>) -> impl Responder {
    println!("创建用户: {:?}", user);
    HttpResponse::Created().json(User {
        name: user.name.clone(),
        age: user.age,
    })
}

// 返回 JSON
async fn list_users() -> impl Responder {
    let users = vec![
        User { name: "Alice".into(), age: 30 },
        User { name: "Bob".into(), age: 25 },
    ];
    HttpResponse::Ok().json(users)
}
```

## 状态管理

用 `web::Data` 在线程间共享应用状态：

```rust
use std::sync::Mutex;
use actix_web::{web, App, HttpServer, HttpResponse, Responder};

struct AppState {
    app_name: String,
    counter: Mutex<u64>,
}

async fn info(data: web::Data<AppState>) -> impl Responder {
    let mut counter = data.counter.lock().unwrap();
    *counter += 1;
    HttpResponse::Ok().body(format!(
        "{} 已被访问 {} 次",
        data.app_name, *counter
    ))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let state = web::Data::new(AppState {
        app_name: String::from("我的 Actix 应用"),
        counter: Mutex::new(0),
    });

    HttpServer::new(move || {
        App::new()
            .app_data(state.clone())
            .route("/", web::get().to(info))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
```

## 中间件

Actix-web 内置了常用中间件：

```rust
use actix_web::middleware::Logger;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::default().default_filter_or("info"));

    HttpServer::new(|| {
        App::new()
            .wrap(Logger::default())     // 请求日志
            .wrap(Logger::new("%a %{User-Agent}i"))  // 自定义日志格式
            .route("/", web::get().to(index))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
```

## 一句话小结

Actix-web 性能极高，适合对吞吐和延迟敏感的 API 服务。路由清晰，JSON 处理便捷，中间件生态丰富。下一篇讲另一个 Rust Web 框架——[Axum 入门](../02Axum入门/)。

## 练习

用 Actix-web 实现一个 REST API：
- `GET /api/health` 返回 `{"status": "ok"}`
- `POST /api/echo` 接收任意 JSON 并原样返回

{{< details title="参考答案" >}}
```rust
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use serde_json::Value;

async fn health() -> impl Responder {
    HttpResponse::Ok().json(serde_json::json!({"status": "ok"}))
}

async fn echo(body: web::Json<Value>) -> impl Responder {
    HttpResponse::Ok().json(body.into_inner())
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/api/health", web::get().to(health))
            .route("/api/echo", web::post().to(echo))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
```
{{< /details >}}
