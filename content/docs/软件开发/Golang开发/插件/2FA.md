---
title: "双因素认证（2FA）"
weight: 10
date: 2026-06-05
tags: ["Go", "2FA", "安全", "TOTP"]
---

在 Go 项目里实现 **TOTP（基于时间的一次性密码，Time-based One-Time Password）** 双因素认证（2FA），可以借助 Google Authenticator、Authy 等 App 扫描二维码生成 6 位动态验证码。





OTP 是 One-Time Password的简写，表示一次性密码。

HOTP 是HMAC-based One-Time Password的简写，表示基于HMAC算法加密的一次性密码。

是事件同步，通过某一特定的事件次序及相同的种子值作为输入，通过HASH算法运算出一致的密码。

TOTP 是Time-based One-Time Password的简写，表示基于时间戳算法的一次性密码。 

是时间同步，基于客户端的动态口令和动态口令验证服务器的时间比对，一般每60秒产生一个新口令，要求客户端和服务器能够十分精确的保持正确的时钟，客户端和服务端基于时间计算的动态口令才能一致。　



## 1. 基础原理

- **TOTP 算法**：基于 RFC 6238（在 HOTP 基础上加上时间因子）。
- **要素**：
  - `secret`：为用户生成的密钥（通常 base32 编码存储在 DB）。
  - `timeStep`：默认 30 秒。
  - `codeLength`：默认 6 位数字。
- 用户使用 Google Authenticator 扫描二维码（包含账号和 secret），之后每 30 秒生成一个动态验证码。

------

## 2. 使用的库

推荐库：

- `github.com/pquerna/otp`
- 支持 TOTP/HOTP + 生成二维码（PNG）

安装：

```text
go get github.com/pquerna/otp
go get github.com/pquerna/otp/totp
```

------

## 3. 完整代码示例

### 生成用户绑定二维码

```go
package main

import (
	"fmt"
	"log"
	"os"

	"github.com/pquerna/otp/totp"
	"github.com/pquerna/otp"
)

func main() {
	// 为用户生成一个 secret（保存在数据库）
	key, err := totp.Generate(totp.GenerateOpts{
		Issuer:      "MyGoApp",     // 应用名称（显示在 Google Authenticator 里）
		AccountName: "user@example.com", // 用户账号
		SecretSize:  32,            // 密钥长度
		Algorithm:   otp.AlgorithmSHA1, // Google Auth 默认 SHA1
	})
	if err != nil {
		log.Fatal(err)
	}

	// 打印 secret（存数据库）
	fmt.Println("Secret:", key.Secret())

	// 导出为 otpauth URL（生成二维码用）
	fmt.Println("URL:", key.URL())

	// 生成二维码 PNG 文件
	img, err := key.Image(200, 200)
	if err != nil {
		log.Fatal(err)
	}
	file, _ := os.Create("qrcode.png")
	defer file.Close()
	err = png.Encode(file, img)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("二维码已生成: qrcode.png (用 Google Authenticator 扫描)")
}
```

------

### 验证用户输入的 TOTP

```go
package main

import (
	"fmt"
	"time"

	"github.com/pquerna/otp/totp"
)

func main() {
	// 假设 secret 是数据库中存的用户专属密钥
	secret := "JBSWY3DPEHPK3PXP" // 示例

	// 用户输入的 6 位验证码（从前端传入）
	userCode := "123456"

	// 校验
	valid := totp.Validate(userCode, secret)
	if valid {
		fmt.Println("✅ 验证成功，允许登录")
	} else {
		fmt.Println("❌ 验证失败")
	}

	// 也可以自定义时间容差（允许前后 1 个时间窗口）
	valid = totp.ValidateCustom(userCode, secret, time.Now(), totp.ValidateOpts{
		Period:    30,
		Skew:      1, // 容忍用户时钟快/慢一个周期
		Digits:    6,
		Algorithm: totp.AlgorithmSHA1,
	})
	if valid {
		fmt.Println("✅ 验证成功 (带时间容错)")
	} else {
		fmt.Println("❌ 验证失败 (带时间容错)")
	}
}
```

------

## 4. 项目中如何接入

1. **用户绑定阶段**：
   - 后端为用户生成 `secret` 和二维码。
   - 用户扫码保存到 Google Authenticator。
   - 后端存储用户 secret 到数据库（加密存储）。
2. **登录阶段**：
   - 用户输入账号 + 密码 → 验证密码正确。
   - 再输入 TOTP 验证码 → 调用 `totp.Validate` 验证。
   - 双因素认证通过 → 颁发 JWT / Session。
3. **安全存储**：
   - `secret` 不要明文存储，建议用 AES 或 KMS 加密。
   - 如果用户需要重置 2FA，可以重新生成 secret。