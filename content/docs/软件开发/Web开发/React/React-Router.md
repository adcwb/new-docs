---
title: "React Router 7"
weight: 30
date: 2026-06-26
tags: ["React", "React Router", "路由", "前端", "SPA"]
---

React Router 7 是 React 官方路由库的最新版本，同时支持**纯路由库模式**（与 React Router 6 兼容）和**框架模式**（基于 Vite 构建，类似 Next.js）。本文重点介绍纯路由库模式。

## 安装

```bash
npm install react-router
```

## 基础配置

```jsx
// main.jsx
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router'
import App from './App'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </StrictMode>
)
```

```jsx
// App.jsx
import { Routes, Route } from 'react-router'
import Home from './pages/Home'
import About from './pages/About'
import UserDetail from './pages/UserDetail'
import NotFound from './pages/NotFound'
import Layout from './components/Layout'

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Home />} />            {/* / */}
        <Route path="about" element={<About />} />   {/* /about */}
        <Route path="users/:id" element={<UserDetail />} /> {/* /users/42 */}
      </Route>
      <Route path="*" element={<NotFound />} />
    </Routes>
  )
}
```

```jsx
// Layout.jsx — 嵌套路由的容器
import { Outlet, NavLink } from 'react-router'

export default function Layout() {
  return (
    <div>
      <nav>
        {/* NavLink 在激活时自动添加 active 类 */}
        <NavLink to="/" end>首页</NavLink>
        <NavLink to="/about">关于</NavLink>
      </nav>

      <main>
        <Outlet />  {/* 子路由在此渲染 */}
      </main>
    </div>
  )
}
```

## 常用 Hooks

### useParams — 路由参数

```jsx
import { useParams } from 'react-router'

function UserDetail() {
  const { id } = useParams()   // 对应路由 path 中的 :id

  return <h1>用户 #{id}</h1>
}
```

### useNavigate — 编程式跳转

```jsx
import { useNavigate } from 'react-router'

function LoginForm() {
  const navigate = useNavigate()

  async function handleSubmit(e) {
    e.preventDefault()
    await login(formData)

    navigate('/dashboard')          // 跳转
    navigate(-1)                    // 后退
    navigate('/login', { replace: true })  // 替换（不保留历史）
    navigate('/user/42', {
      state: { from: 'login' }      // 传递 state（不出现在 URL）
    })
  }

  return <form onSubmit={handleSubmit}>...</form>
}
```

### useLocation — 当前路由信息

```jsx
import { useLocation } from 'react-router'

function Page() {
  const location = useLocation()

  console.log(location.pathname)  // "/users/42"
  console.log(location.search)    // "?tab=posts"
  console.log(location.hash)      // "#comments"
  console.log(location.state)     // navigate() 传入的 state

  return <p>当前路径：{location.pathname}</p>
}
```

### useSearchParams — 查询字符串

```jsx
import { useSearchParams } from 'react-router'

function SearchPage() {
  const [searchParams, setSearchParams] = useSearchParams()

  const query = searchParams.get('q') || ''
  const page = parseInt(searchParams.get('page') || '1')

  function handleSearch(newQuery) {
    setSearchParams({ q: newQuery, page: '1' })
  }

  function nextPage() {
    setSearchParams(prev => {
      prev.set('page', String(page + 1))
      return prev
    })
  }

  return (
    <div>
      <input value={query} onChange={e => handleSearch(e.target.value)} />
      <button onClick={nextPage}>下一页（第 {page} 页）</button>
    </div>
  )
}
```

## 路由守卫（鉴权）

React Router 没有内置守卫，通常用高阶组件或包装 Route 实现：

```jsx
// components/PrivateRoute.jsx
import { Navigate, useLocation } from 'react-router'
import { useAuth } from '@/hooks/useAuth'

export function PrivateRoute({ children }) {
  const { isLoggedIn } = useAuth()
  const location = useLocation()

  if (!isLoggedIn) {
    // 重定向到登录页，并记录来源路径
    return <Navigate to="/login" state={{ from: location }} replace />
  }

  return children
}
```

```jsx
// 在路由配置中使用
<Route
  path="/dashboard"
  element={
    <PrivateRoute>
      <Dashboard />
    </PrivateRoute>
  }
/>
```

登录成功后跳回原页面：

```jsx
function LoginPage() {
  const navigate = useNavigate()
  const location = useLocation()
  const from = location.state?.from?.pathname || '/'

  async function handleLogin() {
    await doLogin()
    navigate(from, { replace: true })  // 跳回来源页
  }
}
```

## 懒加载

```jsx
import { lazy, Suspense } from 'react'
import { Routes, Route } from 'react-router'

// 动态导入，Vite/Webpack 自动分割 chunk
const Dashboard = lazy(() => import('./pages/Dashboard'))
const Profile = lazy(() => import('./pages/Profile'))

export default function App() {
  return (
    <Suspense fallback={<div>加载中…</div>}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/profile" element={<Profile />} />
      </Routes>
    </Suspense>
  )
}
```

## 数据加载（loader）

React Router 6.4+ 引入了基于 Data API 的 loader，在路由切换时预加载数据：

```jsx
import { createBrowserRouter, RouterProvider, useLoaderData } from 'react-router'

// 定义 loader 函数
async function userLoader({ params }) {
  const res = await fetch(`/api/users/${params.id}`)
  if (!res.ok) throw new Response('用户不存在', { status: 404 })
  return res.json()
}

// 路由配置
const router = createBrowserRouter([
  {
    path: '/users/:id',
    loader: userLoader,
    element: <UserDetail />,
    errorElement: <ErrorPage />,
  }
])

// 组件中使用 loader 数据
function UserDetail() {
  const user = useLoaderData()  // 已加载好的数据，无需 useEffect + useState
  return <h1>{user.name}</h1>
}

// 根组件
function Root() {
  return <RouterProvider router={router} />
}
```

{{< callout type="info" >}}
Data Router（`createBrowserRouter`）与 `<BrowserRouter>` 不可混用。推荐新项目直接使用 Data Router，它还支持 `action`（表单提交处理）、`defer`（流式加载）等特性。
{{< /callout >}}
