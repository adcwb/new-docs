---
title: "Casbin 权限模型"
weight: 30
date: 2026-06-05
tags: ["Go", "Casbin", "权限控制", "RBAC"]
---

## PERM元模型

- **Policy：策略**
- **Effect：效果**
- **Request：请求**
- **Matchers：匹配器**



### 请求定义

用来定义访问请求的结构模板，默认采用三元组的格式

- `sub`：求发起的主体（用户/服务）
- `obj`：访问的资源（如API端点）
- `act`：操作类型（如GET/POST）

```ini
[request_definition]
r = sub, obj, act
```

>
>
>eg：一个请求可能是`alice, data1, read`，表示用户alice尝试对资源data1执行read操作





### 策略定义

描述具体权限规则的存储格式

- `sub`：策略中的主体。
- `obj`：策略中的对象。
- `act`：策略中的操作类型。

- `eft`（effect）：策略效果（allow/deny），可选字段，默认allow

```ini
[policy_definition]
p = sub, obj, act, eft

```

>
>
>策略文件中的每一行称为一个策略规则，每条策略规则通常以形如p、p2的策略类型开头
>
>p, alice, data1, read 
>
>p, bob, data2, write
>
>这表示用户alice可以读取data1，用户bob可以写入data2



### 策略效果

```ini
[policy_effect]
e = some(where (p.eft == allow))
e = !some(where (p.eft == deny))
e = some(where (p.eft == allow)) && !some(where (p.eft == deny))
e = priority(p.eft) || deny
e = subjectPriority(p.eft)
```



策略效果定义了如何合并多个匹配的策略规则来决定最终的访问结果。常见的策略效果有：

- `e = some(where (p.eft == allow))`：只要有一个策略规则允许，则允许访问。
- `e = !some(where (p.eft == deny))`：如果没有一个策略规则拒绝，则允许访问。
- `e = all(where (p.eft == allow))`：所有的策略规则都允许，才允许访问。

在以下配置中：

- `e = some(where (p.eft == allow)) && !some(where (p.eft == deny))` 这意味着必须至少有一个匹配的策略规则`allow`，并且不能有任何匹配的策略规则`deny`。因此，这种方式同时支持允许和拒绝授权，并且拒绝会覆盖。

>注意：
>
>	虽然设计了如上所述的策略效果语法，但当前的实现仅使用硬编码的策略效果。这是因为我们发现这种程度的灵活性需求并不大。因此，目前您必须使用内置的策略效果之一，而不能自定义。



### 匹配器

匹配器定义了请求与策略的匹配逻辑

匹配器中可以使用算术运算符`+, -, *, /`和逻辑运算符。`&&, ||, !`

- 完全匹配：`r.sub == p.sub`
- 前缀匹配：`keyMatch(r.obj, p.obj)`
- 正则匹配：`regexMatch(r.act, p.act)`

```ini
[matchers]
 m = r.sub == p.sub && r.act == p.act && r.obj == p.obj
 
 m = r.sub.Name in (r.obj.Admins)
 # 支持特殊运算符in
```

>示例
>
>r.sub == p.sub && keyMatch(r.obj, p.obj) && regexMatch(r.act, p.act) || r.sub == "root"
>
>表示主体与策略主体相匹配，且对象通过前缀匹配，操作通过正则表达式匹配，或者主体是 `root` 时允许访问。

如果您需要多个策略定义或多个匹配器，可以使用`p2`或`m2`作为示例。实际上，上面提到的四个部分都可以使用多种类型，语法`r`后面跟着一个数字，例如`r2`或`e2`。默认情况下，这四个部分应该一一对应。例如，您的`r2`部分将仅使用`m2`匹配器来匹配`p2`策略





## 访问模型

- 一个模型配置（CONF）至少应该有四个部分：
  - `[request_definition]`
  - `[policy_definition]`
  - `[policy_effect]`
  - [matchers]
- 如果模型使用基于角色的访问控制（RBAC），则也应包括该`[role_definition]`部分
- 模型配置 (CONF) 可以包含注释。注释以`#`符号开头，`#`符号之后的所有内容都将被注释掉



具体访问控制模型可参考官方文档：[支持的型号](https://casbin.org/docs/supported-models)

仓库地址：https://github.com/casbin/casbin/tree/master/examples

### 访问控制列表(ACL)

ACL是最简单的访问控制模型，直接定义用户对资源的权限

```ini
# basic_model.conf

[request_definition]
r = sub, obj, act

[policy_definition]
p = sub, obj, act

[policy_effect]
e = some(where (p.eft == allow))

[matchers]
m = r.sub == p.sub && r.obj == p.obj && r.act == p.act


# basic_policy.csv
p, alice, data1, read
p, bob, data2, write
```



### 基于角色的访问控制(RBAC)

RBAC是一种通过角色关联用户与权限的访问控制模型

在RBAC中，为用户分配资源的角色，角色可以包含任意操作。

```ini
[request_definition]
r = sub, obj, act

[policy_definition]
p = sub, obj, act

[role_definition]
g = _, _

[policy_effect]
e = some(where (p.eft == allow))

[matchers]
m = g(r.sub, p.sub) && r.obj == p.obj && r.act == p.act
```





