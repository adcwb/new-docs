---
title: "Angular 路由与响应式表单"
weight: 30
date: 2026-06-26
tags: ["Angular", "路由", "响应式表单", "HttpClient", "前端"]
---

本文覆盖 Angular 路由（Router）和响应式表单（Reactive Forms）的核心用法，以及与后端交互的 HttpClient。这三部分是构建真实 Angular 应用的关键基础设施。

## 路由配置

### 基础路由

```typescript
// app.routes.ts
import { Routes } from '@angular/router';

export const routes: Routes = [
  { path: '', redirectTo: 'home', pathMatch: 'full' },
  { path: 'home', component: HomeComponent },
  { path: 'users', component: UserListComponent },
  { path: 'users/:id', component: UserDetailComponent },
  // 懒加载（推荐，减少首屏体积）
  {
    path: 'admin',
    loadComponent: () =>
      import('./admin/admin.component').then(m => m.AdminComponent),
  },
  // 懒加载子路由
  {
    path: 'settings',
    loadChildren: () =>
      import('./settings/settings.routes').then(m => m.settingsRoutes),
  },
  { path: '**', component: NotFoundComponent },
];
```

```typescript
// app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideRouter, withViewTransitions } from '@angular/router';
import { routes } from './app.routes';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes, withViewTransitions()),  // 开启视图过渡动画
  ],
};
```

### 嵌套路由

```typescript
// settings.routes.ts
export const settingsRoutes: Routes = [
  {
    path: '',
    component: SettingsLayoutComponent,
    children: [
      { path: 'profile', component: ProfileComponent },
      { path: 'security', component: SecurityComponent },
    ]
  }
];
```

```html
<!-- settings-layout.component.html -->
<nav>
  <a routerLink="profile" routerLinkActive="active">个人资料</a>
  <a routerLink="security" routerLinkActive="active">安全设置</a>
</nav>
<router-outlet />
```

### 读取路由信息

```typescript
import { Component, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { toSignal } from '@angular/core/rxjs-interop';

@Component({ ... })
export class UserDetailComponent {
  private route = inject(ActivatedRoute);
  private router = inject(Router);

  // 路由参数（转为 Signal）
  userId = toSignal(this.route.paramMap.pipe(
    map(params => params.get('id'))
  ));

  // 查询参数
  tab = toSignal(this.route.queryParamMap.pipe(
    map(params => params.get('tab') ?? 'info')
  ));

  goBack() {
    this.router.navigate(['/users']);
  }

  goToProfile(id: string) {
    this.router.navigate(['/users', id], { queryParams: { tab: 'profile' } });
  }
}
```

### 路由守卫

```typescript
// guards/auth.guard.ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '@/services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.isLoggedIn()) {
    return true;
  }
  // 重定向到登录页，携带目标路径
  return router.createUrlTree(['/login'], {
    queryParams: { returnUrl: state.url }
  });
};
```

```typescript
// 在路由配置中使用
{
  path: 'admin',
  component: AdminComponent,
  canActivate: [authGuard],
}
```

## 响应式表单

### 基础用法

```typescript
import { Component, inject } from '@angular/core';
import {
  FormGroup, FormControl, Validators, ReactiveFormsModule
} from '@angular/forms';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
      <div>
        <label>邮箱</label>
        <input type="email" formControlName="email">
        @if (email.invalid && email.touched) {
          @if (email.errors?.['required']) {
            <span class="error">邮箱不能为空</span>
          }
          @if (email.errors?.['email']) {
            <span class="error">邮箱格式不正确</span>
          }
        }
      </div>

      <div>
        <label>密码</label>
        <input type="password" formControlName="password">
        @if (password.invalid && password.touched) {
          <span class="error">密码至少 6 位</span>
        }
      </div>

      <button type="submit" [disabled]="loginForm.invalid || loading">
        {{ loading ? '登录中…' : '登录' }}
      </button>
    </form>
  `,
})
export class LoginComponent {
  loading = false;

  loginForm = new FormGroup({
    email: new FormControl('', [Validators.required, Validators.email]),
    password: new FormControl('', [Validators.required, Validators.minLength(6)]),
  });

  // 便捷 getter，模板中用 email 代替 loginForm.get('email')
  get email() { return this.loginForm.get('email')! }
  get password() { return this.loginForm.get('password')! }

  onSubmit() {
    if (this.loginForm.invalid) return;

    this.loading = true;
    const { email, password } = this.loginForm.value;
    // 调用登录服务...
  }
}
```

### FormBuilder（简写）

```typescript
import { FormBuilder, Validators } from '@angular/forms';

@Component({ ... })
export class RegisterComponent {
  private fb = inject(FormBuilder);

  // 使用 FormBuilder 简化创建
  registerForm = this.fb.group({
    username: ['', [Validators.required, Validators.minLength(3)]],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
    confirmPassword: [''],
  }, {
    validators: passwordMatchValidator  // 组级验证器
  });
}

// 自定义验证器
function passwordMatchValidator(group: AbstractControl) {
  const pwd = group.get('password')?.value;
  const confirm = group.get('confirmPassword')?.value;
  return pwd === confirm ? null : { passwordMismatch: true };
}
```

### 常用内置验证器

| 验证器 | 说明 |
| :-- | :-- |
| `Validators.required` | 不能为空 |
| `Validators.email` | 合法邮箱格式 |
| `Validators.minLength(n)` | 最短 n 个字符 |
| `Validators.maxLength(n)` | 最长 n 个字符 |
| `Validators.min(n)` | 数值不小于 n |
| `Validators.max(n)` | 数值不大于 n |
| `Validators.pattern(regex)` | 正则表达式匹配 |

### 动态表单控件（FormArray）

```typescript
import { FormArray, FormControl, FormBuilder } from '@angular/forms';

@Component({
  template: `
    <div formArrayName="emails">
      @for (ctrl of emailsArray.controls; track $index; let i = $index) {
        <input [formControlName]="i">
        <button (click)="removeEmail(i)">删除</button>
      }
    </div>
    <button (click)="addEmail()">添加邮箱</button>
  `,
})
export class MultiEmailComponent {
  private fb = inject(FormBuilder);

  form = this.fb.group({
    emails: this.fb.array([
      new FormControl('', Validators.email)
    ])
  });

  get emailsArray() {
    return this.form.get('emails') as FormArray;
  }

  addEmail() {
    this.emailsArray.push(new FormControl('', Validators.email));
  }

  removeEmail(index: number) {
    this.emailsArray.removeAt(index);
  }
}
```

## HttpClient

### 基础配置

```typescript
// app.config.ts
import { provideHttpClient, withInterceptors } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([authInterceptor, errorInterceptor])
    ),
  ],
};
```

### 服务中发起请求

```typescript
import { Injectable, inject, signal } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { catchError, tap, throwError } from 'rxjs';

export interface User {
  id: number;
  name: string;
  email: string;
}

@Injectable({ providedIn: 'root' })
export class UserService {
  private http = inject(HttpClient);
  private baseUrl = '/api/users';

  private _users = signal<User[]>([]);
  readonly users = this._users.asReadonly();

  // GET 列表
  loadUsers(page = 1, pageSize = 10) {
    const params = new HttpParams()
      .set('page', page)
      .set('pageSize', pageSize);

    return this.http.get<User[]>(this.baseUrl, { params }).pipe(
      tap(data => this._users.set(data)),
      catchError(err => {
        console.error('加载用户失败', err);
        return throwError(() => err);
      })
    );
  }

  // GET 单个
  getUser(id: number) {
    return this.http.get<User>(`${this.baseUrl}/${id}`);
  }

  // POST 创建
  createUser(user: Omit<User, 'id'>) {
    return this.http.post<User>(this.baseUrl, user).pipe(
      tap(newUser => this._users.update(list => [...list, newUser]))
    );
  }

  // PUT 更新
  updateUser(id: number, updates: Partial<User>) {
    return this.http.put<User>(`${this.baseUrl}/${id}`, updates);
  }

  // DELETE 删除
  deleteUser(id: number) {
    return this.http.delete(`${this.baseUrl}/${id}`).pipe(
      tap(() => this._users.update(list => list.filter(u => u.id !== id)))
    );
  }
}
```

### 拦截器（Interceptor）

```typescript
// interceptors/auth.interceptor.ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '@/services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const token = auth.getToken();

  if (token) {
    // 给所有请求附加 Authorization 头
    const authReq = req.clone({
      headers: req.headers.set('Authorization', `Bearer ${token}`)
    });
    return next(authReq);
  }

  return next(req);
};
```

```typescript
// interceptors/error.interceptor.ts
import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      if (error.status === 401) {
        router.navigate(['/login']);
      }
      if (error.status === 403) {
        router.navigate(['/forbidden']);
      }
      return throwError(() => error);
    })
  );
};
```

### 在组件中订阅

```typescript
@Component({ ... })
export class UserListComponent implements OnInit {
  private userService = inject(UserService);

  users = this.userService.users;  // Signal
  loading = signal(false);
  error = signal('');

  ngOnInit() {
    this.loading.set(true);
    this.userService.loadUsers().subscribe({
      next: () => this.loading.set(false),
      error: (err) => {
        this.error.set(err.message);
        this.loading.set(false);
      }
    });
  }

  deleteUser(id: number) {
    this.userService.deleteUser(id).subscribe();
  }
}
```
