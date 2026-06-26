---
title: "Angular 核心概念"
weight: 20
date: 2026-06-26
tags: ["Angular", "Angular 19", "Signals", "组件", "前端", "TypeScript"]
---

Angular 19 以 **Standalone 组件**为默认架构（不再需要 NgModule），并将 **Signals** 作为首选的响应式原语，取代 Zone.js 驱动的变更检测。本文覆盖现代 Angular 的核心概念。

## Standalone 组件

Angular 17+ 默认创建 Standalone 组件，无需在 NgModule 中声明，直接通过 `imports` 声明依赖。

```typescript
// app.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,                    // 标记为独立组件
  imports: [CommonModule, RouterOutlet], // 直接导入所需模块/组件
  template: `
    <h1>{{ title }}</h1>
    <router-outlet />
  `,
})
export class AppComponent {
  title = 'my-app';
}
```

```typescript
// main.ts — 直接引导 Standalone 组件
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { appConfig } from './app/app.config';

bootstrapApplication(AppComponent, appConfig);
```

## Signals — 响应式状态

Angular 16+ 引入 Signals，Angular 19 中已稳定。Signals 让状态变更可追踪，无需 Zone.js 即可精确触发更新。

### 基本用法

```typescript
import { Component, signal, computed, effect } from '@angular/core';

@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <p>计数：{{ count() }}</p>
    <p>双倍：{{ doubleCount() }}</p>
    <button (click)="increment()">+1</button>
    <button (click)="reset()">重置</button>
  `,
})
export class CounterComponent {
  // signal：创建响应式值
  count = signal(0);

  // computed：从其他 signal 派生（类似 Vue 的 computed）
  doubleCount = computed(() => this.count() * 2);

  constructor() {
    // effect：自动追踪依赖，副作用（类似 Vue 的 watchEffect）
    effect(() => {
      console.log(`count 变为：${this.count()}`);
    });
  }

  increment() {
    this.count.update(v => v + 1);  // 基于旧值更新
  }

  reset() {
    this.count.set(0);              // 直接设置新值
  }
}
```

### Signal 操作方法

```typescript
const name = signal('Alice');

// 读取
name()                      // "Alice"（调用函数读取）

// 修改
name.set('Bob')             // 直接设置
name.update(v => v + '!')   // 基于旧值更新

// 只读视图（暴露给外部，防止外部修改）
const readonlyName = name.asReadonly()
```

### 在模板中使用 Signals

```typescript
@Component({
  template: `
    @if (user()) {
      <p>欢迎，{{ user()!.name }}</p>
    } @else {
      <p>请登录</p>
    }

    @for (item of items(); track item.id) {
      <li>{{ item.name }}</li>
    }
  `,
})
export class ProfileComponent {
  user = signal<User | null>(null);
  items = signal<Item[]>([]);
}
```

{{< callout type="info" >}}
Angular 17+ 引入了新的**控制流语法**（`@if`、`@for`、`@switch`），取代旧的 `*ngIf`、`*ngFor` 结构指令，性能更好，无需额外导入 `CommonModule`。
{{< /callout >}}

## 模板语法

### 数据绑定

```html
<!-- 属性绑定：将表达式绑定到 DOM 属性 -->
<img [src]="imageUrl" [alt]="imageAlt">
<button [disabled]="isLoading">提交</button>

<!-- 事件绑定：处理 DOM 事件 -->
<button (click)="handleClick()">点击</button>
<input (input)="onInput($event)" (keydown.enter)="onEnter()">

<!-- 双向绑定（需要 FormsModule） -->
<input [(ngModel)]="username">

<!-- 文本插值 -->
<p>{{ user.name }}</p>

<!-- Class 与 Style 绑定 -->
<div [class.active]="isActive" [class.disabled]="isDisabled">...</div>
<div [ngClass]="{ active: isActive, dark: isDarkMode }">...</div>
<p [style.color]="textColor" [style.fontSize.px]="fontSize">...</p>
```

### 控制流

```html
<!-- @if / @else-if / @else -->
@if (status === 'loading') {
  <app-spinner />
} @else if (status === 'error') {
  <p class="error">{{ errorMsg }}</p>
} @else {
  <app-content [data]="data" />
}

<!-- @for（必须指定 track） -->
@for (user of users; track user.id) {
  <li>{{ user.name }}</li>
} @empty {
  <li>暂无数据</li>
}

<!-- @switch -->
@switch (role) {
  @case ('admin') { <app-admin-panel /> }
  @case ('user')  { <app-user-panel /> }
  @default        { <p>未知角色</p> }
}
```

## 组件输入/输出

```typescript
import { Component, input, output, model } from '@angular/core';

@Component({
  selector: 'app-input-demo',
  standalone: true,
  template: `
    <input [value]="value()" (input)="value.set($event.target.value)">
    <button (click)="submitted.emit(value())">提交</button>
  `,
})
export class InputDemoComponent {
  // input()：Signal 化的输入（Angular 17.1+）
  label = input<string>('');          // 可选输入，默认 ''
  required = input.required<string>() // 必填输入

  // model()：双向绑定 input（等效于 value + valueChange）
  value = model<string>('');

  // output()：事件发射
  submitted = output<string>();
}
```

```html
<!-- 父组件使用 -->
<app-input-demo
  label="用户名"
  [(value)]="username"
  (submitted)="onSubmit($event)"
/>
```

## 服务与依赖注入

```typescript
// services/user.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { signal } from '@angular/core';

@Injectable({
  providedIn: 'root'  // 全局单例，自动注册
})
export class UserService {
  private http = inject(HttpClient);  // inject() 函数（推荐代替构造函数注入）
  private _users = signal<User[]>([]);

  // 只暴露只读 signal
  readonly users = this._users.asReadonly();

  loadUsers() {
    this.http.get<User[]>('/api/users').subscribe(data => {
      this._users.set(data);
    });
  }

  getUserById(id: number) {
    return this.http.get<User>(`/api/users/${id}`);
  }
}
```

```typescript
// 在组件中使用服务
@Component({ ... })
export class UserListComponent {
  private userService = inject(UserService);

  // 直接用服务的 signal
  users = this.userService.users;

  ngOnInit() {
    this.userService.loadUsers();
  }
}
```

## 管道（Pipe）

管道用于在模板中转换数据，不修改原始值：

```html
{{ birthday | date:'yyyy-MM-dd' }}       <!-- 日期格式化 -->
{{ price | currency:'CNY':'symbol' }}    <!-- 货币格式化 -->
{{ title | uppercase }}                  <!-- 转大写 -->
{{ items | slice:0:5 }}                  <!-- 截取数组 -->
{{ data | json }}                        <!-- JSON 调试 -->
{{ text | async }}                       <!-- 订阅 Observable/Promise -->
```

自定义管道：

```typescript
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'truncate', standalone: true })
export class TruncatePipe implements PipeTransform {
  transform(value: string, limit = 50): string {
    return value.length > limit ? value.slice(0, limit) + '…' : value;
  }
}
```

```html
{{ article.content | truncate:100 }}
```
