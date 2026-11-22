-- Migration 008: Wallet transactions

CREATE TABLE wallet_transactions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  type            wallet_txn_type NOT NULL,
  amount          DECIMAL(10, 2) NOT NULL,
  balance_after   DECIMAL(10, 2) NOT NULL,       -- snapshot of balance after this txn
  order_id        UUID REFERENCES orders(id),    -- set for debits
  txn_ref         VARCHAR(100) NOT NULL UNIQUE,  -- unique reference for every transaction
  gateway_payment_id VARCHAR(100),               -- Razorpay payment id for top-ups
  description     VARCHAR(255),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_wallet_txn_amount CHECK (amount > 0),
  CONSTRAINT chk_wallet_balance_after CHECK (balance_after >= 0)
);

CREATE INDEX idx_wallet_txn_user ON wallet_transactions(user_id);
CREATE INDEX idx_wallet_txn_order ON wallet_transactions(order_id)
  WHERE order_id IS NOT NULL;
CREATE INDEX idx_wallet_txn_ref ON wallet_transactions(txn_ref);
CREATE INDEX idx_wallet_txn_created ON wallet_transactions(created_at DESC);
