-- Migration 004: Menu categories, items and add-ons

CREATE TABLE menu_categories (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          VARCHAR(100) NOT NULL UNIQUE,
  description   TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_menu_categories_order ON menu_categories(display_order);

CREATE TRIGGER trg_menu_categories_updated_at
  BEFORE UPDATE ON menu_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─── Menu items ──────────────────────────────────────────────────────────────

CREATE TABLE menu_items (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category_id     UUID NOT NULL REFERENCES menu_categories(id) ON DELETE RESTRICT,
  name            VARCHAR(150) NOT NULL,
  description     TEXT,
  price           DECIMAL(10, 2) NOT NULL,
  image_url       VARCHAR(500),
  is_available    BOOLEAN NOT NULL DEFAULT TRUE,
  is_veg          BOOLEAN NOT NULL DEFAULT TRUE,
  display_order   INTEGER NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_menu_item_price CHECK (price >= 0)
);

CREATE INDEX idx_menu_items_category ON menu_items(category_id);
CREATE INDEX idx_menu_items_available ON menu_items(is_available);

CREATE TRIGGER trg_menu_items_updated_at
  BEFORE UPDATE ON menu_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─── Add-ons / customizations ────────────────────────────────────────────────

CREATE TABLE menu_item_addons (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  menu_item_id  UUID NOT NULL REFERENCES menu_items(id) ON DELETE CASCADE,
  name          VARCHAR(100) NOT NULL,          -- e.g. "Extra cheese", "No onion"
  price         DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  is_available  BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT chk_addon_price CHECK (price >= 0)
);

CREATE INDEX idx_addons_menu_item ON menu_item_addons(menu_item_id);
