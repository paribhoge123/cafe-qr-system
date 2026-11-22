-- Migration 007: Kitchen Order Tickets (KOT)

CREATE SEQUENCE kot_number_seq START 1;

CREATE TABLE kots (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  kot_number      VARCHAR(20) NOT NULL UNIQUE,  -- e.g. "KOT-0021"
  order_id        UUID NOT NULL UNIQUE REFERENCES orders(id) ON DELETE RESTRICT,
  status          kot_status NOT NULL DEFAULT 'new',
  notes           TEXT,                          -- kitchen-level notes
  generated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  accepted_at     TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-generate KOT numbers
CREATE OR REPLACE FUNCTION generate_kot_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.kot_number = 'KOT-' || LPAD(nextval('kot_number_seq')::TEXT, 4, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_kots_kot_number
  BEFORE INSERT ON kots
  FOR EACH ROW EXECUTE FUNCTION generate_kot_number();

CREATE TRIGGER trg_kots_updated_at
  BEFORE UPDATE ON kots
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE INDEX idx_kots_order ON kots(order_id);
CREATE INDEX idx_kots_status ON kots(status);
CREATE INDEX idx_kots_generated ON kots(generated_at DESC);
