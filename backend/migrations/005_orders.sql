-- Migration 005: Orders and order items

CREATE TABLE orders (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number    VARCHAR(20) NOT NULL UNIQUE,  -- human-readable e.g. "ORD-0042"
  table_id        UUID NOT NULL REFERENCES cafe_tables(id) ON DELETE RESTRICT,
  user_id         UUID REFERENCES users(id) ON DELETE SET NULL,
  status          order_status NOT NULL DEFAULT 'draft',
  payment_method  payment_method,
  subtotal        DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  tax_amount      DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  discount_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  total_amount    DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  special_instructions TEXT,
  placed_at       TIMESTAMPTZ,                  -- when customer confirmed order
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_order_amounts CHECK (
    subtotal >= 0 AND tax_amount >= 0 AND
    discount_amount >= 0 AND total_amount >= 0
  )
);

-- Auto-generate human-readable order numbers
CREATE SEQUENCE order_number_seq START 1;

CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
  NEW.order_number = 'ORD-' || LPAD(nextval('order_number_seq')::TEXT, 4, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_orders_order_number
  BEFORE INSERT ON orders
  FOR EACH ROW EXECUTE FUNCTION generate_order_number();

CREATE TRIGGER trg_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Indexes
CREATE INDEX idx_orders_table ON orders(table_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_placed_at ON orders(placed_at DESC);
CREATE INDEX idx_orders_number ON orders(order_number);

-- ─── Order items ─────────────────────────────────────────────────────────────

CREATE TABLE order_items (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id        UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  menu_item_id    UUID NOT NULL REFERENCES menu_items(id) ON DELETE RESTRICT,
  quantity        INTEGER NOT NULL,
  unit_price      DECIMAL(10, 2) NOT NULL,      -- price at time of order
  total_price     DECIMAL(10, 2) NOT NULL,
  customization   TEXT,                          -- free-text cooking notes
  status          item_status NOT NULL DEFAULT 'pending',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_order_item_qty CHECK (quantity > 0),
  CONSTRAINT chk_order_item_price CHECK (unit_price >= 0 AND total_price >= 0)
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_menu_item ON order_items(menu_item_id);

CREATE TRIGGER trg_order_items_updated_at
  BEFORE UPDATE ON order_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─── Order item add-ons ──────────────────────────────────────────────────────

CREATE TABLE order_item_addons (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_item_id   UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
  addon_id        UUID NOT NULL REFERENCES menu_item_addons(id) ON DELETE RESTRICT,
  quantity        INTEGER NOT NULL DEFAULT 1,
  unit_price      DECIMAL(10, 2) NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_item_addons_item ON order_item_addons(order_item_id);
