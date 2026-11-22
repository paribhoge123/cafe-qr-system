-- Migration 009: Udhaar (credit) ledger

CREATE TABLE udhaar_ledger (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  type            udhaar_entry_type NOT NULL,
  amount          DECIMAL(10, 2) NOT NULL,
  outstanding_after DECIMAL(10, 2) NOT NULL,     -- snapshot of outstanding after entry
  order_id        UUID REFERENCES orders(id),    -- set for debit entries
  recorded_by     UUID REFERENCES users(id),     -- owner who recorded repayment
  note            TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_udhaar_amount CHECK (amount > 0),
  CONSTRAINT chk_udhaar_outstanding CHECK (outstanding_after >= 0)
);

CREATE INDEX idx_udhaar_user ON udhaar_ledger(user_id);
CREATE INDEX idx_udhaar_order ON udhaar_ledger(order_id)
  WHERE order_id IS NOT NULL;
CREATE INDEX idx_udhaar_created ON udhaar_ledger(created_at DESC);
