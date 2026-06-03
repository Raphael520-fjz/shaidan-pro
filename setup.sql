-- ============================================================
-- 筛单系统 Pro - Supabase 数据库初始化脚本
-- 在 Supabase SQL Editor 中执行此文件
-- ============================================================

-- 1. 创建 profiles 表（用户扩展信息）
CREATE TABLE IF NOT EXISTS profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  agency_name TEXT,
  phone       TEXT,
  plan        TEXT DEFAULT 'trial',
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 创建 orders 表（订单数据）
CREATE TABLE IF NOT EXISTS orders (
  id          BIGSERIAL PRIMARY KEY,
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  district    VARCHAR(50) NOT NULL,
  grade       VARCHAR(50) NOT NULL,
  subject     VARCHAR(50) NOT NULL,
  detail      TEXT NOT NULL,
  date_tag    VARCHAR(20) DEFAULT '未标注',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 3. 索引（加速筛选查询）
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_district ON orders(user_id, district);
CREATE INDEX IF NOT EXISTS idx_orders_grade ON orders(user_id, grade);
CREATE INDEX IF NOT EXISTS idx_orders_subject ON orders(user_id, subject);
CREATE INDEX IF NOT EXISTS idx_orders_date_tag ON orders(user_id, date_tag);

-- 4. Row Level Security（数据隔离：用户只能访问自己的数据）
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- orders 表策略
DROP POLICY IF EXISTS "Users can read own orders" ON orders;
CREATE POLICY "Users can read own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own orders" ON orders;
CREATE POLICY "Users can insert own orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own orders" ON orders;
CREATE POLICY "Users can update own orders" ON orders
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own orders" ON orders;
CREATE POLICY "Users can delete own orders" ON orders
  FOR DELETE USING (auth.uid() = user_id);

-- profiles 表策略
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
CREATE POLICY "Users can read own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- 5. 新用户自动创建 profile 的触发器
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, agency_name, plan)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'agency_name', '未命名'), 'trial');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
