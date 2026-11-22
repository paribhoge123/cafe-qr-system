-- Migration 010: Seed data
-- Default owner account and sample menu to get started

-- ─── Default owner account ───────────────────────────────────────────────────
-- Password: Admin@1234  (bcrypt hash — CHANGE THIS before production!)
INSERT INTO users (id, role, name, email, password_hash)
VALUES (
  uuid_generate_v4(),
  'owner',
  'Cafe Owner',
  'owner@cafe.com',
  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4oSPGvJUym'
) ON CONFLICT (email) DO NOTHING;

-- ─── Sample cafe tables ──────────────────────────────────────────────────────
INSERT INTO cafe_tables (table_number, label) VALUES
  (1, 'Table 1'),
  (2, 'Table 2'),
  (3, 'Table 3'),
  (4, 'Window Seat'),
  (5, 'Corner Table')
ON CONFLICT (table_number) DO NOTHING;

-- ─── Sample menu categories ──────────────────────────────────────────────────
INSERT INTO menu_categories (name, display_order) VALUES
  ('Hot Beverages', 1),
  ('Cold Beverages', 2),
  ('Snacks', 3),
  ('Main Course', 4),
  ('Desserts', 5)
ON CONFLICT (name) DO NOTHING;

-- ─── Sample menu items ───────────────────────────────────────────────────────
-- Hot Beverages
WITH cat AS (SELECT id FROM menu_categories WHERE name = 'Hot Beverages')
INSERT INTO menu_items (category_id, name, description, price, is_veg, display_order)
SELECT cat.id, items.name, items.desc, items.price, TRUE, items.ord
FROM cat, (VALUES
  ('Masala Chai', 'Classic Indian spiced tea', 30.00, 1),
  ('Filter Coffee', 'South Indian style filter coffee', 40.00, 2),
  ('Cappuccino', 'Espresso with steamed milk foam', 80.00, 3),
  ('Green Tea', 'Light and refreshing green tea', 50.00, 4)
) AS items(name, desc, price, ord)
ON CONFLICT DO NOTHING;

-- Cold Beverages
WITH cat AS (SELECT id FROM menu_categories WHERE name = 'Cold Beverages')
INSERT INTO menu_items (category_id, name, description, price, is_veg, display_order)
SELECT cat.id, items.name, items.desc, items.price, TRUE, items.ord
FROM cat, (VALUES
  ('Cold Coffee', 'Chilled coffee with milk', 90.00, 1),
  ('Mango Lassi', 'Fresh mango blended with yogurt', 70.00, 2),
  ('Lemonade', 'Fresh squeezed lemon with soda', 60.00, 3)
) AS items(name, desc, price, ord)
ON CONFLICT DO NOTHING;

-- Snacks
WITH cat AS (SELECT id FROM menu_categories WHERE name = 'Snacks')
INSERT INTO menu_items (category_id, name, description, price, is_veg, display_order)
SELECT cat.id, items.name, items.desc, items.price, items.veg, items.ord
FROM cat, (VALUES
  ('Veg Sandwich', 'Grilled sandwich with vegetables', 80.00, TRUE, 1),
  ('Paneer Tikka', 'Spiced cottage cheese tikka', 150.00, TRUE, 2),
  ('French Fries', 'Crispy golden fries with dip', 90.00, TRUE, 3),
  ('Chicken Wrap', 'Grilled chicken in a tortilla wrap', 160.00, FALSE, 4)
) AS items(name, desc, price, veg, ord)
ON CONFLICT DO NOTHING;
