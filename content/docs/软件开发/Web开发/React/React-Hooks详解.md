---
title: "React Hooks 详解"
weight: 20
date: 2026-06-26
tags: ["React", "Hooks", "useState", "useEffect", "前端"]
---

React Hooks 是 React 16.8 引入的特性，让函数组件也能拥有状态和副作用。React 19 继续扩充了 Hooks 体系。本文覆盖所有常用 Hooks，并给出实际场景示例。

## Hooks 分类速览

| 类别 | Hook | 用途 |
| :-- | :-- | :-- |
| 状态 | `useState` | 声明状态变量 |
| 状态 | `useReducer` | 复杂状态逻辑，类似 Redux |
| 上下文 | `useContext` | 读取 Context 值 |
| 引用 | `useRef` | 保存不触发重渲染的值；访问 DOM |
| 副作用 | `useEffect` | 连接外部系统（网络、DOM、订阅） |
| 副作用 | `useLayoutEffect` | 同 useEffect，在浏览器绘制前同步执行 |
| 性能 | `useMemo` | 缓存计算结果 |
| 性能 | `useCallback` | 缓存函数引用 |
| 并发 | `useTransition` | 将状态更新标记为非阻塞 |
| 并发 | `useDeferredValue` | 延迟更新非关键 UI |
| 其他 | `useId` | 生成唯一 ID（用于无障碍属性） |
| React 19 | `useActionState` | 管理 Action 的状态（表单） |

## useState

声明状态变量，返回 `[当前值, 更新函数]`。

```jsx
import { useState } from 'react'

function Counter() {
  const [count, setCount] = useState(0)
  const [user, setUser] = useState({ name: 'Alice', age: 25 })

  return (
    <div>
      <p>计数：{count}</p>
      <button onClick={() => setCount(count + 1)}>+1</button>
      <button onClick={() => setCount(prev => prev - 1)}>-1（函数式更新）</button>

      {/* 更新对象：必须展开旧值 */}
      <button onClick={() => setUser(prev => ({ ...prev, age: prev.age + 1 }))}>
        年龄 +1
      </button>
    </div>
  )
}
```

{{< callout type="warning" >}}
**不要直接修改 state**：`user.age++` 不会触发重渲染。必须用 setter 并传入新对象/数组。
{{< /callout >}}

## useReducer

当状态逻辑复杂（多个子值互相依赖，或下一状态依赖操作类型）时，`useReducer` 比多个 `useState` 更清晰。

```jsx
import { useReducer } from 'react'

// reducer 函数：纯函数，根据 action 返回新 state
function tasksReducer(tasks, action) {
  switch (action.type) {
    case 'added':
      return [...tasks, { id: action.id, text: action.text, done: false }]
    case 'changed':
      return tasks.map(t => t.id === action.task.id ? action.task : t)
    case 'deleted':
      return tasks.filter(t => t.id !== action.id)
    default:
      throw Error('未知 action：' + action.type)
  }
}

function TaskApp() {
  const [tasks, dispatch] = useReducer(tasksReducer, [])

  function addTask(text) {
    dispatch({ type: 'added', id: Date.now(), text })
  }

  function deleteTask(id) {
    dispatch({ type: 'deleted', id })
  }

  return (
    <ul>
      {tasks.map(task => (
        <li key={task.id}>
          {task.text}
          <button onClick={() => deleteTask(task.id)}>删除</button>
        </li>
      ))}
      <button onClick={() => addTask('新任务')}>添加</button>
    </ul>
  )
}
```

## useContext

避免 props 逐层传递，让深层组件直接读取共享数据。

```jsx
import { createContext, useContext, useState } from 'react'

// 1. 创建 Context（通常在单独文件中）
const ThemeContext = createContext('light')

// 2. Provider 包裹子树，提供值
function App() {
  const [theme, setTheme] = useState('light')
  return (
    <ThemeContext.Provider value={{ theme, setTheme }}>
      <Page />
    </ThemeContext.Provider>
  )
}

// 3. 任意后代组件消费
function Button() {
  const { theme, setTheme } = useContext(ThemeContext)
  return (
    <button
      className={`btn-${theme}`}
      onClick={() => setTheme(t => t === 'light' ? 'dark' : 'light')}
    >
      当前主题：{theme}
    </button>
  )
}
```

## useRef

两种主要用途：
1. **保存可变值**：不触发重渲染（类似实例变量）
2. **访问 DOM 节点**

```jsx
import { useRef, useEffect } from 'react'

function StopWatch() {
  const timerRef = useRef(null)   // 保存定时器 ID，改变不触发渲染
  const inputRef = useRef(null)   // 引用 DOM 节点

  function start() {
    timerRef.current = setInterval(() => console.log('tick'), 1000)
  }

  function stop() {
    clearInterval(timerRef.current)
  }

  useEffect(() => {
    // 组件挂载后聚焦输入框
    inputRef.current.focus()
  }, [])

  return (
    <div>
      <input ref={inputRef} placeholder="自动获得焦点" />
      <button onClick={start}>开始</button>
      <button onClick={stop}>停止</button>
    </div>
  )
}
```

## useEffect

连接组件与外部系统（网络请求、订阅、手动操作 DOM 等）。

```jsx
import { useState, useEffect } from 'react'

function UserProfile({ userId }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // 每次 userId 变化时重新获取
    setLoading(true)

    let ignore = false   // 防止旧请求结果覆盖新结果

    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => {
        if (!ignore) {
          setUser(data)
          setLoading(false)
        }
      })

    // 清理函数：在下次 effect 执行前 或 组件卸载时运行
    return () => { ignore = true }
  }, [userId])   // 依赖项数组

  if (loading) return <p>加载中…</p>
  return <p>用户：{user?.name}</p>
}
```

**依赖项规则**：

| 依赖项 | 行为 |
| :-- | :-- |
| `[a, b]` | `a` 或 `b` 变化时执行 |
| `[]` | 仅在组件挂载时执行一次 |
| 不传（省略） | 每次渲染后都执行（通常不推荐） |

{{< callout type="info" >}}
不要在 useEffect 里直接更新 state 然后再 fetch——这会导致瀑布式请求。推荐使用 React Query、SWR 等数据获取库，或 React 19 的 `use` + Suspense 方案。
{{< /callout >}}

## useMemo 与 useCallback

跳过不必要的计算或重渲染，**只在性能实际有问题时使用**。

```jsx
import { useMemo, useCallback, memo } from 'react'

// useMemo：缓存计算结果
function ProductList({ products, filterText }) {
  // 仅当 products 或 filterText 变化时重新计算
  const filtered = useMemo(
    () => products.filter(p => p.name.includes(filterText)),
    [products, filterText]
  )

  return <ul>{filtered.map(p => <li key={p.id}>{p.name}</li>)}</ul>
}

// useCallback：缓存函数引用（配合 memo 组件使用）
function Parent({ productId }) {
  const handleSubmit = useCallback((orderDetails) => {
    // productId 变化时才创建新函数
    sendOrder(productId, orderDetails)
  }, [productId])

  return <ChildForm onSubmit={handleSubmit} />
}

// memo 包裹：props 不变时跳过重渲染
const ChildForm = memo(function ChildForm({ onSubmit }) {
  return <button onClick={() => onSubmit({ qty: 1 })}>下单</button>
})
```

## 自定义 Hook

自定义 Hook 以 `use` 开头，内部可调用其他 Hook，封装可复用的有状态逻辑。

```jsx
// hooks/useFetch.js
import { useState, useEffect } from 'react'

export function useFetch(url) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    let ignore = false
    setLoading(true)

    fetch(url)
      .then(res => {
        if (!res.ok) throw new Error('请求失败')
        return res.json()
      })
      .then(json => { if (!ignore) setData(json) })
      .catch(err => { if (!ignore) setError(err.message) })
      .finally(() => { if (!ignore) setLoading(false) })

    return () => { ignore = true }
  }, [url])

  return { data, loading, error }
}
```

```jsx
// 在任意组件中使用
import { useFetch } from '@/hooks/useFetch'

function UserList() {
  const { data: users, loading, error } = useFetch('/api/users')

  if (loading) return <p>加载中…</p>
  if (error) return <p>错误：{error}</p>
  return (
    <ul>
      {users.map(u => <li key={u.id}>{u.name}</li>)}
    </ul>
  )
}
```

## useTransition（React 18+）

将某个状态更新标记为**非阻塞低优先级**，避免输入框卡顿等问题。

```jsx
import { useState, useTransition } from 'react'

function SearchPage() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [isPending, startTransition] = useTransition()

  function handleChange(e) {
    setQuery(e.target.value)   // 高优先级：立即更新输入框

    startTransition(() => {
      // 低优先级：搜索结果可以延迟，不阻塞输入
      setResults(heavySearch(e.target.value))
    })
  }

  return (
    <div>
      <input value={query} onChange={handleChange} />
      {isPending && <span>搜索中…</span>}
      <ResultList results={results} />
    </div>
  )
}
```
