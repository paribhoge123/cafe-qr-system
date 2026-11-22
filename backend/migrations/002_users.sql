-- Migration 002: Users table

CREATE TABLE users (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  role              user_role NOT NULL DEFAULT 'customer',
  name              VARCHAR(100),
  phone             VARCHAR(15) UNIQUE,                -- customers login via phone
  email             VARCHAR(100) UNIQUE,               -- staff/owner login via email
  password_hash     VARCHAR(255),                      -- staff/owner only
  wallet_balance    DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  udhaar_enabled    BOOLEAN NOT NULL DEFAULT FALSE,
  udhaar_limit      DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- customers use phone, staff use email+password
  CONSTRAINT chk_customer_has_phone
    CHECK (role != 'customer' OR phone IS NOT NULL),
  CONSTRAINT chk_staff_has_email
    CHECK (role = 'customer' OR email IS NOT NULL),
  CONSTRAINT chk_wallet_non_negative
    CHECK (wallet_balance >= 0),
  CONSTRAINT chk_udhaar_limit_non_negative
    CHECK (udhaar_limit >= 0)
);

-- Indexes
CREATE INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_role ON users(role);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
