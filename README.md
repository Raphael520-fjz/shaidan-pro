# 筛单系统 Pro

家教订单管理SaaS · 云端同步 · 多设备共享

## 快速开始

### 第一步：创建 Supabase 项目

1. 打开 [supabase.com](https://supabase.com) 注册账号
2. 点击 "New Project" 创建项目
3. 选择 **Singapore** 区域（离上海最近）
4. 设置数据库密码（自己记住）
5. 等待项目创建完成（约2分钟）

### 第二步：创建数据库表

1. 在 Supabase 控制台左侧点击 **SQL Editor**
2. 点击 **New query**
3. 复制 [setup.sql](setup.sql) 的全部内容粘贴进去
4. 点击 **Run** 执行

### 第三步：配置连接信息

1. 在 Supabase 控制台左侧点击 **Settings → API**
2. 复制 **Project URL**（例：https://xxxxx.supabase.co）
3. 复制 **anon public key**（例：eyJhbGci...长字符串）
4. 打开 `index.html`，找到：
   ```
   const SUPABASE_URL = '__SUPABASE_URL__';
   const SUPABASE_ANON_KEY = '__SUPABASE_ANON_KEY__';
   ```
5. 替换为你的实际值

### 第四步：部署

```bash
cd "C:/Users/范佳泽/Desktop/shaidan-pro"
git add . && git commit -m "v1.0" && git push
```

### 第五步：迁移旧数据

用 `migrate.html` 自动迁移，或在 Pro 中粘贴导入。

## 文件说明

| 文件 | 用途 |
|------|------|
| index.html | Pro版筛单系统主应用 |
| setup.sql | Supabase建表脚本 |
| migrate.html | 数据迁移工具 |
