---
title: "Pinia 状态管理"
weight: 50
date: 2026-06-26
tags: ["Vue", "Pinia", "状态管理", "前端", "Vue3"]
---

Pinia 是 Vue 官方推荐的状态管理库（取代 Vuex），专为 Vue 3 设计，具有更简洁的 API、完整的 TypeScript 支持和开发工具集成。核心概念只有三个：**State（状态）、Getters（计算值）、Actions（操作）**。

## 安装与配置

```bash
npm install pinia
```

```javascript
// main.js
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'

const app = createApp(App)
app.use(createPinia())  // 必须在 use(router) 之前注册
app.mount('#app')
```

## 定义 Store

Pinia 推荐使用**组合式 Store**（类似 `<script setup>`），也支持选项式 Store。

### 组合式 Store（推荐）

```javascript
// stores/counter.js
import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

export const useCounterStore = defineStore('counter', () => {
  // state：响应式变量
  const count = ref(0)
  const name = ref('Eduardo')

  // getters：计算属性
  const doubleCount = computed(() => count.value * 2)

  // actions：修改 state 的方法（可异步）
  function increment() {
    count.value++
  }

  function reset() {
    count.value = 0
  }

  async function fetchInitialCount() {
    const res = await fetch('/api/count')
    const data = await res.json()
    count.value = data.count
  }

  return { count, name, doubleCount, increment, reset, fetchInitialCount }
})
```

### 选项式 Store

```javascript
// stores/user.js
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    currentUser: null,
    token: '',
  }),

  getters: {
    isLoggedIn: (state) => !!state.token,
    username: (state) => state.currentUser?.name ?? '游客',
  },

  actions: {
    async login(credentials) {
      const res = await fetch('/api/login', {
        method: 'POST',
        body: JSON.stringify(credentials),
      })
      const data = await res.json()
      this.token = data.token
      this.currentUser = data.user
    },

    logout() {
      this.token = ''
      this.currentUser = null
    },
  },
})
```

## 在组件中使用

```vue
<script setup>
import { storeToRefs } from 'pinia'
import { useCounterStore } from '@/stores/counter'
import { useUserStore } from '@/stores/user'

const counterStore = useCounterStore()
const userStore = useUserStore()

// 直接解构会失去响应性！使用 storeToRefs 保持响应性
const { count, doubleCount } = storeToRefs(counterStore)
const { isLoggedIn, username } = storeToRefs(userStore)

// actions 直接解构（函数不需要响应性）
const { increment, reset } = counterStore
</script>

<template>
  <div>
    <p>计数：{{ count }}，双倍：{{ doubleCount }}</p>
    <button @click="increment">+1</button>
    <button @click="reset">重置</button>

    <p v-if="isLoggedIn">欢迎，{{ username }}</p>
    <button v-else @click="userStore.login({ name: 'Alice', pwd: '123' })">
      登录
    </button>
  </div>
</template>
```

## 直接修改 State

```javascript
const store = useCounterStore()

// 方式一：直接赋值（选项式 Store 在 action 外，或组合式 Store）
store.count++

// 方式二：$patch 批量修改（性能更好，只触发一次渲染）
store.$patch({
  count: store.count + 1,
  name: 'new name',
})

// 方式三：$patch 函数形式（适合数组操作）
store.$patch((state) => {
  state.items.push({ id: Date.now(), name: '新项目' })
  state.count++
})

// 重置为初始 state
store.$reset()

// 替换整个 state
store.$state = { count: 10, name: 'replaced' }
```

## 订阅 Store 变化

```javascript
const store = useCounterStore()

// 订阅 state 变化（类似 Vuex 的 subscribe）
const unsubscribe = store.$subscribe((mutation, state) => {
  console.log(mutation.type)    // 'direct' | 'patch object' | 'patch function'
  console.log(mutation.storeId) // 'counter'
  // 可用于持久化到 localStorage
  localStorage.setItem('counter', JSON.stringify(state))
})

// 取消订阅
unsubscribe()

// 订阅 action
store.$onAction(({ name, args, after, onError }) => {
  console.log(`action "${name}" 被调用，参数：`, args)
  after(result => console.log('action 完成，结果：', result))
  onError(error => console.error('action 出错：', error))
})
```

## Store 间调用

```javascript
// stores/cart.js
import { defineStore } from 'pinia'
import { useUserStore } from './user'

export const useCartStore = defineStore('cart', {
  actions: {
    async checkout() {
      const userStore = useUserStore()
      if (!userStore.isLoggedIn) {
        throw new Error('请先登录')
      }
      // 结算逻辑...
    }
  }
})
```

## 持久化插件（pinia-plugin-persistedstate）

```bash
npm install pinia-plugin-persistedstate
```

```javascript
// main.js
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)
```

```javascript
// 在 Store 中开启持久化
export const useAuthStore = defineStore('auth', {
  state: () => ({ token: '', user: null }),
  persist: true,  // 默认持久化全部 state 到 localStorage
})

// 细粒度配置
export const useSettingsStore = defineStore('settings', {
  state: () => ({ theme: 'light', language: 'zh' }),
  persist: {
    key: 'app-settings',       // 自定义 localStorage key
    storage: sessionStorage,   // 改用 sessionStorage
    pick: ['theme'],           // 只持久化 theme（不持久化 language）
  },
})
```

## 与 Vue Router 集成

```javascript
// router/index.js — 在守卫中使用 Store
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({ ... })

router.beforeEach((to) => {
  // 注意：必须在 router.beforeEach 的回调内部调用 useStore
  const auth = useAuthStore()

  if (to.meta.requiresAuth && !auth.isLoggedIn) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
})

export default router
```
