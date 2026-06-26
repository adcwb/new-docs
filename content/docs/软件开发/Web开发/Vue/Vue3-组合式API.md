---
title: "Vue 3 组合式 API"
weight: 30
date: 2026-06-26
tags: ["Vue", "Vue3", "组合式API", "Composition API", "前端"]
---

Vue 3 推荐使用**组合式 API（Composition API）**配合 `<script setup>` 语法糖来编写组件。相比 Vue 2 的选项式 API，组合式 API 将同一功能的代码集中在一起，更易维护、更好支持 TypeScript，也更方便逻辑复用。

## 与选项式 API 的对比

| 维度 | 选项式 API（Vue 2） | 组合式 API（Vue 3） |
| :-- | :-- | :-- |
| 代码组织 | 按 `data`/`methods`/`computed` 分散 | 按功能聚合，一处读懂 |
| 逻辑复用 | Mixin（命名冲突、来源不清晰） | 自定义 Hook（composable），清晰 |
| TypeScript | 支持有限 | 原生完整支持 |
| 推荐场景 | 简单页面、迁移项目 | **Vue 3 新项目首选** |

## `<script setup>` 语法

`<script setup>` 是 `setup()` 函数的编译时语法糖，**顶层声明的变量和函数自动暴露给模板**，无需 `return`。

```vue
<script setup>
import { ref, onMounted } from 'vue'

// 响应式数据
const count = ref(0)

function increment() {
  count.value++
}

// 生命周期钩子
onMounted(() => {
  console.log('组件已挂载，count =', count.value)
})
</script>

<template>
  <button @click="increment">点击次数：{{ count }}</button>
</template>
```

## 响应式系统

### ref — 基础响应式值

`ref` 用于包装**任意类型**的值（原始类型首选 `ref`）。在 JS 中通过 `.value` 访问，模板中自动解包无需 `.value`。

```vue
<script setup>
import { ref } from 'vue'

const name = ref('Alice')
const count = ref(0)
const list = ref([1, 2, 3])

// 修改时必须用 .value
name.value = 'Bob'
list.value.push(4)
</script>

<template>
  <!-- 模板中自动解包，不需要 .value -->
  <p>{{ name }}</p>
  <p>{{ count }}</p>
</template>
```

### reactive — 对象响应式

`reactive` 用于包装**对象/数组**，返回深层响应式代理。直接通过属性访问，无需 `.value`。

```vue
<script setup>
import { reactive } from 'vue'

const state = reactive({
  name: 'Alice',
  age: 25,
  hobbies: ['读书', '编程']
})

// 直接修改属性
state.name = 'Bob'
state.hobbies.push('旅行')
</script>
```

{{< callout type="warning" >}}
不要解构 `reactive` 对象，解构后的变量会**失去响应性**。若需解构，使用 `toRefs()`：
```js
import { reactive, toRefs } from 'vue'
const state = reactive({ name: 'Alice', age: 25 })
const { name, age } = toRefs(state)  // name.value, age.value 依然响应
```
{{< /callout >}}

### computed — 计算属性

```vue
<script setup>
import { ref, computed } from 'vue'

const firstName = ref('张')
const lastName = ref('三')

// 只读计算属性
const fullName = computed(() => firstName.value + lastName.value)

// 可写计算属性
const fullNameWritable = computed({
  get: () => firstName.value + ' ' + lastName.value,
  set: (val) => {
    [firstName.value, lastName.value] = val.split(' ')
  }
})
</script>

<template>
  <p>全名：{{ fullName }}</p>
</template>
```

### watch — 侦听器

```vue
<script setup>
import { ref, reactive, watch, watchEffect } from 'vue'

const count = ref(0)
const state = reactive({ name: 'Alice' })

// 侦听单个 ref
watch(count, (newVal, oldVal) => {
  console.log(`count: ${oldVal} → ${newVal}`)
})

// 侦听多个来源
watch([count, () => state.name], ([newCount, newName]) => {
  console.log(newCount, newName)
})

// 深度侦听对象（deep: true）
watch(state, (newState) => {
  console.log('state 变化了', newState)
}, { deep: true })

// watchEffect：自动追踪依赖，立即执行
watchEffect(() => {
  // 访问到的响应式数据都会被追踪
  console.log(`count 是 ${count.value}，name 是 ${state.name}`)
})
</script>
```

## 生命周期钩子

组合式 API 中的钩子需从 `vue` 导入，对应关系：

| 选项式 API | 组合式 API（`<script setup>`） |
| :-- | :-- |
| `beforeCreate` / `created` | `setup()` 本身（无对应钩子） |
| `beforeMount` | `onBeforeMount` |
| `mounted` | `onMounted` |
| `beforeUpdate` | `onBeforeUpdate` |
| `updated` | `onUpdated` |
| `beforeUnmount` | `onBeforeUnmount` |
| `unmounted` | `onUnmounted` |

```vue
<script setup>
import { onMounted, onUpdated, onUnmounted } from 'vue'

onMounted(() => {
  console.log('DOM 已挂载，可以操作 DOM 或发起请求')
})

onUnmounted(() => {
  // 清理定时器、取消订阅等
})
</script>
```

## 组件通信

### defineProps — 父传子

```vue
<!-- 子组件 ChildComp.vue -->
<script setup>
// 方式一：运行时声明
const props = defineProps({
  title: String,
  count: {
    type: Number,
    default: 0
  },
  required: {
    type: Boolean,
    required: true
  }
})

// 方式二：TypeScript 类型声明（推荐）
// const props = defineProps<{ title: string; count?: number }>()
</script>

<template>
  <h2>{{ props.title }}（{{ props.count }}）</h2>
</template>
```

```vue
<!-- 父组件 -->
<template>
  <ChildComp title="标题" :count="42" :required="true" />
</template>
```

### defineEmits — 子传父

```vue
<!-- 子组件 -->
<script setup>
const emit = defineEmits(['update', 'delete'])

function handleUpdate() {
  emit('update', { id: 1, value: 'new' })
}
</script>

<template>
  <button @click="handleUpdate">更新</button>
  <button @click="emit('delete', 1)">删除</button>
</template>
```

```vue
<!-- 父组件 -->
<template>
  <ChildComp @update="onUpdate" @delete="onDelete" />
</template>

<script setup>
function onUpdate(payload) { console.log(payload) }
function onDelete(id) { console.log('删除', id) }
</script>
```

### v-model 双向绑定

Vue 3 中 `v-model` 默认使用 `modelValue` prop 和 `update:modelValue` 事件，支持多个 v-model：

```vue
<!-- 子组件 MyInput.vue -->
<script setup>
defineProps(['modelValue'])
defineEmits(['update:modelValue'])
</script>

<template>
  <input
    :value="modelValue"
    @input="$emit('update:modelValue', $event.target.value)"
  />
</template>
```

```vue
<!-- 父组件 -->
<template>
  <MyInput v-model="text" />
  <!-- 等价于：<MyInput :modelValue="text" @update:modelValue="text = $event" /> -->
</template>
```

### provide / inject — 跨层传值

```vue
<!-- 祖先组件 -->
<script setup>
import { provide, ref } from 'vue'

const theme = ref('dark')
provide('theme', theme)            // 提供响应式值
provide('updateTheme', (val) => { theme.value = val })  // 提供修改方法
</script>
```

```vue
<!-- 任意后代组件 -->
<script setup>
import { inject } from 'vue'

const theme = inject('theme')
const updateTheme = inject('updateTheme')
</script>

<template>
  <div :class="theme">
    <button @click="updateTheme('light')">切换亮色</button>
  </div>
</template>
```

## 可组合函数（Composable）

将可复用的有状态逻辑提取为函数，命名以 `use` 开头：

```javascript
// composables/useFetch.js
import { ref } from 'vue'

export function useFetch(url) {
  const data = ref(null)
  const error = ref(null)
  const loading = ref(true)

  fetch(url)
    .then(res => res.json())
    .then(json => { data.value = json })
    .catch(err => { error.value = err })
    .finally(() => { loading.value = false })

  return { data, error, loading }
}
```

```vue
<!-- 使用 composable -->
<script setup>
import { useFetch } from '@/composables/useFetch'

const { data, error, loading } = useFetch('/api/users')
</script>

<template>
  <div v-if="loading">加载中…</div>
  <div v-else-if="error">出错了</div>
  <ul v-else>
    <li v-for="user in data" :key="user.id">{{ user.name }}</li>
  </ul>
</template>
```

## 常用模板指令速查

| 指令 | 说明 | 示例 |
| :-- | :-- | :-- |
| `v-bind` / `:` | 动态绑定属性 | `:href="url"` |
| `v-on` / `@` | 绑定事件 | `@click="fn"` |
| `v-model` | 双向绑定 | `v-model="text"` |
| `v-if` / `v-else-if` / `v-else` | 条件渲染（销毁/重建） | `v-if="show"` |
| `v-show` | 条件显示（切换 display） | `v-show="visible"` |
| `v-for` | 列表渲染 | `v-for="(item, i) in list" :key="i"` |
| `v-once` | 只渲染一次 | `v-once` |
| `v-pre` | 跳过编译（展示原始 Mustache） | `v-pre` |
