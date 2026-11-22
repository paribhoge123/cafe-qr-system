-- Migration 006: Payments and payment audit log

CREATE TABLE payments (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id        UUID NOT NULL UNIQUE REFERENCES orders(id) ON DELETE RESTRICT,
  method          payment_method NOT NULL,
  status          payment_status NOT NULL DEFAULT 'initiated',
  amount          DECIMAL(10, 2) NOT NULL,
  currency        VARCHAR(3) NOT NULL DEFAULT 'INR',

  -- Gateway fields (Razorpay)
  gateway_order_id    VARCHAR(100),             -- Razorpay order id
  gateway_payment_id  VARCHAR(100),             -- Razorpay payment id
  gateway_signature   VARCHAR(500),             -- Razorpay signature for verification

  -- Idempotency
  idempotency_key VARCHAR(100) UNIQUE,          -- prevents duplicate payments

  -- Cashier approval fields
  approved_by     UUID REFERENCES users(id),
  approved_at     TIMESTAMPTZ,
  rejection_note  TEXT,

  paid_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_payment_amount CHECK (amount > 0)
);

CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_method ON payments(method);
CREATE INDEX idx_payments_gateway_order ON payments(gateway_order_id)
  WHERE gateway_order_id IS NOT NULL;

CREATE TRIGGER trg_payments_updated_at
  BEFORE UPDATE ON payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─── Payment audit log ───────────────────────────────────────────────────────
-- Every status change is recorded here — full financial traceability

CREATE TABLE payment_audit_log (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payment_id      UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  performed_by    UUID REFERENCES users(id),    -- NULL for system/gateway actions
  action          VARCHAR(50) NOT NULL,          -- e.g. 'approved', 'rejected', 'refunded'
  old_status      payment_status,
  new_status      payment_status NOT NULL,
  note            TEXT,
  metadata        JSONB,                         -- raw gateway response or extra context
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_log_payment ON payment_audit_log(payment_id);
CREATE INDEX idx_audit_log_performed_by ON payment_audit_log(performed_by);
CREATE INDEX idx_audit_log_created ON payment_audit_log(created_at DESC);
