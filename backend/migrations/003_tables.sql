-- Migration 003: Cafe tables and QR session tokens

CREATE TABLE cafe_tables (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  table_number  INTEGER NOT NULL UNIQUE,
  label         VARCHAR(50),                    -- e.g. "Window Seat", "Terrace 2"
  qr_token      VARCHAR(500),                   -- current signed HMAC token
  qr_code_url   VARCHAR(500),                   -- S3/R2 URL of generated QR image
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cafe_tables_number ON cafe_tables(table_number);
CREATE INDEX idx_cafe_tables_active ON cafe_tables(is_active);

CREATE TRIGGER trg_cafe_tables_updated_at
  BEFORE UPDATE ON cafe_tables
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─── QR Session tokens ───────────────────────────────────────────────────────
-- Each scan generates a short-lived session so customers can't manipulate URLs

CREATE TABLE qr_sessions (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  table_id      UUID NOT NULL REFERENCES cafe_tables(id) ON DELETE CASCADE,
  token_hash    VARCHAR(255) NOT NULL UNIQUE,   -- SHA256 of the signed token
  user_id       UUID REFERENCES users(id),      -- set after customer logs in
  is_used       BOOLEAN NOT NULL DEFAULT FALSE,
  expires_at    TIMESTAMPTZ NOT NULL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_qr_sessions_token ON qr_sessions(token_hash);
CREATE INDEX idx_qr_sessions_table ON qr_sessions(table_id);
CREATE INDEX idx_qr_sessions_expires ON qr_sessions(expires_at);
