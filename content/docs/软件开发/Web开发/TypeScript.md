---
title: "TypeScript 基础"
weight: 10
date: 2026-06-26
tags: ["Web", "TypeScript", "前端", "类型系统", "ES6"]
---

TypeScript 是 JavaScript 的**静态类型超集**，由微软开发，文件扩展名为 `.ts`。所有合法的 JS 代码都是合法的 TS 代码。TypeScript 在编译时检查类型错误，编译产物为纯 JavaScript，可运行在任何 JS 环境中。

## 安装与配置

```bash
# 全局安装
npm install -g typescript

# 查看版本
tsc --version

# 编译单文件
tsc hello.ts

# 生成 tsconfig.json
tsc --init
```

### tsconfig.json 常用选项

```json
{
  "compilerOptions": {
    "target": "ES2020",           // 编译目标 JS 版本
    "module": "ESNext",           // 模块系统
    "moduleResolution": "bundler",
    "strict": true,               // 开启全部严格检查（推荐）
    "outDir": "./dist",           // 编译输出目录
    "rootDir": "./src",           // 源码目录
    "declaration": true,          // 生成 .d.ts 声明文件
    "sourceMap": true,            // 生成 source map
    "paths": {
      "@/*": ["./src/*"]          // 路径别名
    },
    "lib": ["ES2020", "DOM"]      // 包含的类型库
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## 基本类型

```typescript
// 原始类型
let name: string = "Alice"
let age: number = 25
let isDone: boolean = false
let big: bigint = 100n

// 特殊类型
let u: undefined = undefined
let n: null = null
let sym: symbol = Symbol("key")

// any：关闭类型检查（尽量避免）
let anything: any = 42
anything = "hello"

// unknown：比 any 安全，使用前必须类型收窄
let input: unknown = getUserInput()
if (typeof input === "string") {
  console.log(input.toUpperCase())  // 安全
}

// never：永远不会有值（抛出异常或无限循环的函数）
function fail(msg: string): never {
  throw new Error(msg)
}

// void：函数无返回值
function log(msg: string): void {
  console.log(msg)
}
```

### 数组与元组

```typescript
// 数组
const nums: number[] = [1, 2, 3]
const strs: Array<string> = ["a", "b"]

// 元组（固定长度和类型）
const pair: [string, number] = ["Alice", 25]
const [username, userAge] = pair  // 解构

// 只读数组
const readonlyArr: readonly number[] = [1, 2, 3]
// readonlyArr.push(4)  // ❌ 编译错误
```

## 联合类型与字面量类型

```typescript
// 联合类型（|）
let id: string | number = "abc123"
id = 42  // 合法

// 字面量类型（精确的值范围）
type Direction = "up" | "down" | "left" | "right"
type StatusCode = 200 | 404 | 500

function move(dir: Direction): void {
  console.log("Moving", dir)
}

// 辨别联合（Discriminated Union）
type Circle = { kind: "circle"; radius: number }
type Square = { kind: "square"; side: number }
type Shape = Circle | Square

function area(shape: Shape): number {
  switch (shape.kind) {
    case "circle": return Math.PI * shape.radius ** 2
    case "square": return shape.side ** 2
  }
}
```

## 类型别名与接口

```typescript
// type 别名
type Point = { x: number; y: number }
type ID = string | number
type Callback<T> = (value: T) => void

// interface 接口
interface User {
  id: number
  name: string
  email?: string           // 可选属性
  readonly createdAt: Date // 只读属性
}

// 接口继承
interface Admin extends User {
  role: "admin" | "superadmin"
  permissions: string[]
}

// 交叉类型（&）：合并多个类型
type StaffUser = User & { department: string }
```

| 对比维度 | `interface` | `type` |
| :-- | :-- | :-- |
| 扩展方式 | `extends` 继承 | `&` 交叉 |
| 重复声明 | 自动合并（声明合并） | 报错 |
| 联合类型 | 不支持 | 支持（`A \| B`） |
| 实现接口 | `implements` | `implements`（对象类型） |
| 推荐场景 | 公共 API 形状、可继承结构 | 复杂组合类型、联合类型 |

## 函数类型

```typescript
// 参数与返回值
function add(a: number, b: number): number {
  return a + b
}

// 可选参数与默认值
function greet(name: string, greeting = "Hello"): string {
  return `${greeting}, ${name}!`
}

// Rest 参数
function sum(...nums: number[]): number {
  return nums.reduce((a, b) => a + b, 0)
}

// 函数类型别名
type MathFn = (a: number, b: number) => number
const multiply: MathFn = (a, b) => a * b

// 函数重载（先声明签名，再实现）
function format(value: string): string
function format(value: number, decimals?: number): string
function format(value: string | number, decimals = 2): string {
  if (typeof value === "string") return value.trim()
  return value.toFixed(decimals)
}
```

## 泛型

泛型让函数和类支持多种类型，同时保留类型信息。

```typescript
// 泛型函数
function identity<T>(value: T): T {
  return value
}
identity<string>("hello")  // 显式指定
identity(42)               // 类型推断

// 泛型约束（extends）
function getLength<T extends { length: number }>(item: T): number {
  return item.length
}
getLength("string")    // ✅
getLength([1, 2, 3])   // ✅
// getLength(42)        // ❌ number 没有 length

// 泛型接口
interface Repository<T> {
  findById(id: number): T | undefined
  findAll(): T[]
  create(item: Omit<T, "id">): T
}

// 泛型类
class Stack<T> {
  private items: T[] = []
  push(item: T): void { this.items.push(item) }
  pop(): T | undefined { return this.items.pop() }
  isEmpty(): boolean { return this.items.length === 0 }
}

const numStack = new Stack<number>()
numStack.push(1)
numStack.pop()  // number | undefined

// 多泛型参数
function zip<A, B>(a: A[], b: B[]): [A, B][] {
  return a.map((item, i) => [item, b[i]])
}
```

## 类

```typescript
class Animal {
  public name: string         // 默认，外部可访问
  protected age: number       // 子类可访问
  private _secret: string     // 仅本类内部可访问
  readonly species: string    // 只读

  // 构造函数参数简写（自动声明并赋值属性）
  constructor(
    public nickname: string,
    protected weight: number,
  ) {
    this.name = nickname
    this.age = 0
    this._secret = "hidden"
    this.species = "Animal"
  }

  // getter / setter
  get info(): string { return `${this.name} (${this.age})` }
  set info(value: string) { this.name = value }

  static create(name: string): Animal { return new Animal(name, 0) }
}

// 继承
class Dog extends Animal {
  constructor(name: string, public breed: string) {
    super(name, 10)  // 必须先调用 super
  }

  bark(): string {
    return `${this.name} says: Woof!`
    // this._secret  // ❌ private 不可访问
    // this.age      // ✅ protected 可访问
  }
}

// 实现接口
interface Flyable {
  fly(): void
  altitude: number
}

class Bird extends Animal implements Flyable {
  altitude = 100
  fly(): void { console.log("Flying at", this.altitude) }
}
```

## 枚举

```typescript
// 数字枚举（默认从 0 开始，支持反向映射）
enum Direction { Up, Down, Left, Right }
console.log(Direction.Up)   // 0
console.log(Direction[0])   // "Up"

// 字符串枚举（推荐，可读性更好）
enum Status {
  Active = "ACTIVE",
  Inactive = "INACTIVE",
  Pending = "PENDING",
}

// const 枚举（编译时内联，无运行时对象，性能更好）
const enum Color { Red = "red", Green = "green", Blue = "blue" }
const c = Color.Red  // 编译后变为字面量 "red"
```

## 工具类型

TypeScript 内置了大量实用的泛型工具类型：

```typescript
interface User {
  id: number
  name: string
  email: string
  age: number
}

// Partial<T> — 所有属性变可选
type PartialUser = Partial<User>

// Required<T> — 所有属性变必填
type RequiredUser = Required<PartialUser>

// Readonly<T> — 所有属性变只读
const frozenUser: Readonly<User> = { id: 1, name: "Alice", email: "a@b.com", age: 25 }

// Pick<T, K> — 选取部分属性
type UserPreview = Pick<User, "id" | "name">
// → { id: number; name: string }

// Omit<T, K> — 排除部分属性
type CreateUserDTO = Omit<User, "id">
// → { name: string; email: string; age: number }

// Record<K, V> — 键值类型映射
type RoleMap = Record<"admin" | "editor" | "viewer", string[]>

// Exclude / Extract — 操作联合类型
type NoString = Exclude<string | number | boolean, string>   // number | boolean
type OnlyStr = Extract<string | number | boolean, string>    // string

// NonNullable<T> — 排除 null 和 undefined
type NotNull = NonNullable<string | null | undefined>  // string

// ReturnType<T> — 获取函数返回值类型
function getUser() { return { id: 1, name: "Alice" } }
type UserResult = ReturnType<typeof getUser>  // { id: number; name: string }

// Parameters<T> — 获取函数参数类型（元组）
type AddParams = Parameters<typeof add>  // [a: number, b: number]

// Awaited<T> — 解包 Promise 类型
type ResolvedUser = Awaited<Promise<User>>  // User
```

## 类型收窄

```typescript
// typeof 收窄
function padLeft(value: string, padding: string | number): string {
  if (typeof padding === "number") {
    return " ".repeat(padding) + value
  }
  return padding + value  // 此处 padding 已推断为 string
}

// instanceof 收窄
function printError(err: Error | string) {
  if (err instanceof Error) {
    console.error(err.message)
  } else {
    console.error(err)
  }
}

// 自定义类型守卫（返回 is 断言）
function isUser(obj: unknown): obj is User {
  return typeof obj === "object" && obj !== null
    && "id" in obj && "name" in obj
}

if (isUser(data)) {
  console.log(data.name)  // 安全，已收窄为 User
}
```

## 装饰器

需在 tsconfig 中启用 `"experimentalDecorators": true`：

```typescript
// 方法装饰器（常用于日志、缓存、验证）
function log(target: any, key: string, descriptor: PropertyDescriptor) {
  const original = descriptor.value
  descriptor.value = function (...args: any[]) {
    console.log(`[${key}] args:`, args)
    const result = original.apply(this, args)
    console.log(`[${key}] result:`, result)
    return result
  }
  return descriptor
}

class MathService {
  @log
  add(a: number, b: number): number {
    return a + b
  }
}
```

## 模块与声明文件

```typescript
// 导出
export interface Config { apiUrl: string; timeout: number }
export function fetchData<T>(url: string): Promise<T> { /* ... */ }
export default class ApiClient { /* ... */ }

// 导入
import ApiClient, { Config, fetchData } from "./api-client"
import type { Config } from "./api-client"  // 仅类型导入，编译后抹除

// 为第三方纯 JS 库补充类型声明
declare module "some-old-lib" {
  export function helper(value: string): number
}

// 扩展全局类型
declare global {
  interface Window {
    myPlugin: { version: string }
  }
}
```
