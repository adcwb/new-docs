---
title: "Vue Router 4"
weight: 40
date: 2026-06-26
tags: ["Vue", "Vue Router", "路由", "前端", "SPA"]
---

Vue Router 4 是 Vue 3 的官方路由库，与 Vue 3 深度集成，支持 Composition API、TypeScript 和 Tree-shaking。本文基于 Vue Router 4.x 最新文档。

## 安装与基础配置

```bash
npm install vue-router@4
```

```javascript
// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import Home from '@/views/Home.vue'
import About from '@/views/About.vue'

const routes = [
  { path: '/', component: Home },
  { path: '/about', component: About },
  // 动态路由（:id 为路由参数）
  { path: '/users/:id', component: () => import('@/views/UserDetail.vue') },
  // 404 页面（*匹配所有未定义路由）
  { path: '/:pathMatch(.*)*', name: 'NotFound', component: () => import('@/views/NotFound.vue') },
]

const router = createRouter({
  history: createWebHistory(),  // HTML5 History 模式（无 #）
  // history: createWebHashHistory(),  // Hash 模式（带 #，无需服务端配置）
  routes,
})

export default router
```

```javascript
// main.js
import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

createApp(App).use(router).mount('#app')
```

## router-link 与 router-view

```vue
<!-- App.vue -->
<template>
  <nav>
    <!-- router-link 替代 <a>，激活时自动加 class="router-link-active" -->
    <router-link to="/">首页</router-link>
    <router-link to="/about">关于</router-link>
    <router-link :to="{ name: 'user', params: { id: 42 } }">用户 42</router-link>
  </nav>

  <!-- 路由组件渲染位置 -->
  <router-view />
</template>
```

`router-link` 会在路径匹配时自动添加 `router-link-active` 类，精确匹配时添加 `router-link-exact-active` 类，可在 CSS 中自定义高亮样式。

## 动态路由与路由参数

```javascript
// 路由配置
{ path: '/users/:id', name: 'user', component: UserDetail }
```

```vue
<!-- UserDetail.vue：在组件中获取参数 -->
<script setup>
import { useRoute } from 'vue-router'

const route = useRoute()

// 路由参数
console.log(route.params.id)     // "42"（字符串）

// 查询字符串（/users/42?tab=posts）
console.log(route.query.tab)     // "posts"

// 完整路径
console.log(route.fullPath)      // "/users/42?tab=posts"
</script>

<template>
  <h1>用户 #{{ route.params.id }}</h1>
</template>
```

## 嵌套路由

```javascript
const routes = [
  {
    path: '/user/:id',
    component: UserLayout,
    children: [
      { path: '',      component: UserHome },     // /user/:id
      { path: 'posts', component: UserPosts },    // /user/:id/posts
      { path: 'profile', component: UserProfile } // /user/:id/profile
    ]
  }
]
```

```vue
<!-- UserLayout.vue：需要嵌套的 router-view -->
<template>
  <div class="user-layout">
    <nav>
      <router-link :to="`/user/${route.params.id}/posts`">文章</router-link>
      <router-link :to="`/user/${route.params.id}/profile`">资料</router-link>
    </nav>
    <router-view />  <!-- 子路由渲染在这里 -->
  </div>
</template>
```

## 编程式导航

```vue
<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

// 跳转（等同于 router-link）
router.push('/about')
router.push({ name: 'user', params: { id: 42 } })
router.push({ path: '/users', query: { page: 2 } })

// 替换（不保留历史记录）
router.replace('/login')

// 前进/后退
router.go(1)
router.go(-1)
router.back()
router.forward()
</script>
```

## 命名路由与命名视图

```javascript
// 命名路由（推荐，路径变更时不需要修改 push 的调用）
const routes = [
  { path: '/user/:id', name: 'user', component: UserDetail }
]

// 命名视图（一个页面多个 router-view）
const routes = [
  {
    path: '/dashboard',
    components: {
      default: DashboardMain,
      sidebar: DashboardSidebar,
      header: DashboardHeader,
    }
  }
]
```

```vue
<router-view name="sidebar" />
<router-view />           <!-- 等价于 name="default" -->
<router-view name="header" />
```

## 导航守卫

### 全局守卫

```javascript
// 全局前置守卫（最常用，做权限控制）
router.beforeEach((to, from) => {
  const isLoggedIn = !!localStorage.getItem('token')

  if (to.meta.requiresAuth && !isLoggedIn) {
    // 返回路由对象表示重定向
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  // 返回 true 或 undefined 表示放行
})

// 全局后置钩子（不能取消导航）
router.afterEach((to, from) => {
  document.title = to.meta.title || '我的应用'
})
```

### 路由元信息（meta）

```javascript
const routes = [
  {
    path: '/admin',
    component: AdminPage,
    meta: {
      requiresAuth: true,
      title: '管理后台',
      roles: ['admin']
    }
  }
]

// 在守卫中访问 to.meta.requiresAuth
```

### 组件内守卫

```vue
<script setup>
import { onBeforeRouteLeave, onBeforeRouteUpdate } from 'vue-router'

// 离开当前路由前触发（常用于表单保存提醒）
onBeforeRouteLeave((to, from) => {
  if (hasUnsavedChanges.value) {
    const confirmed = window.confirm('有未保存的修改，确定离开吗？')
    if (!confirmed) return false  // 取消导航
  }
})

// 路由参数更新时触发（如 /user/1 → /user/2）
onBeforeRouteUpdate((to, from) => {
  loadUser(to.params.id)
})
</script>
```

## 懒加载（路由级代码分割）

```javascript
const routes = [
  // 使用动态 import，Vite/Webpack 自动分割为单独 chunk
  {
    path: '/admin',
    component: () => import('@/views/Admin.vue')
  },
  // 同一 chunk（webpackChunkName 注释对 Vite 也有效）
  {
    path: '/user',
    component: () => import(/* webpackChunkName: "user" */ '@/views/UserHome.vue')
  }
]
```

## 滚动行为

```javascript
const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      // 浏览器前进/后退时恢复位置
      return savedPosition
    }
    if (to.hash) {
      // 锚点跳转
      return { el: to.hash, behavior: 'smooth' }
    }
    // 默认回到顶部
    return { top: 0 }
  }
})
```
