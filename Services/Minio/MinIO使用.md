# MinIO 使用

https://juejin.cn/post/7206973995727372343

## Buckets（桶）
### 创建
```shell
- bucket name：bucket名字。
- versioning: 版本控制允许在同一个键下保留同一个对象的多个版本。
- object locking：对象锁定防止对象被删除。需要支持保留和合法持有。只能在创建桶时启用。
- quota：配额用于限制桶内的数据量。
- retention：保留是指在一段时间内防止对象删除的规则。为了设置桶保留策略，必须启用版本控制。
```
### 配置
```shell
- Summary（概要）：主要是展示当前bucket相关的配置。
- Access Poilcy：private，public，custom。
- Encyption: 就是配置是否加密。
- Anonymous：配置Access Poilcy为custom，可以自己定义那些前缀是只读，那些前缀是读写
- Events：事件，给Bucket绑定事件通知
- Lifecycle（生命周期）：就是配置bucket生命周期
    - After：代表多少天后过期
    - Prefix：文件名前缀
```

## Policies（策略）
MinIO使用基于策略的访问控制(PBAC)来定义经过身份验证的用户有权访问的授权操作和资源。

每个策略描述一个或多个操作和条件，这些操作和条件概括了一个用户或一组用户的权限。

MinIO PBAC是为了兼容AWS IAM策略语法、结构和行为而构建的。每个用户只能访问内置角色显式授予的资源和操作。

默认情况下，MinIO拒绝访问任何其他资源或操作。

AWS IAM策略语法: https://docs.aws.amazon.com/zh_cn/IAM/latest/UserGuide/access_policies.html

## Identity（身份）
用户MinIO用户由唯一的接入密钥(用户名)和对应的密钥(密码)组成。

客户端必须通过指定现有MinlO用户的有效访问密钥(用户名)和相应的密钥(密码)来验证其身份。组提供了一种简化的方法，用于管理具有通用访问模式和工作负载的用户之间的共享权限。用户通过所属组继承对数据和资源的访问权限。
