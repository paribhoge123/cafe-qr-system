-- Migration 001: Extensions and Enums
-- Run this first — all other migrations depend on these types

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- User roles
CREATE TYPE user_role AS ENUM ('owner', 'cashier', 'kitchen', 'customer');

-- Order statuses
CREATE TYPE order_status AS ENUM (
  'draft',
  'pending_payment',
  'awaiting_cashier',
  'payment_confirmed',
  'kot_sent',
  'accepted',
  'preparing',
  'ready',
  'served',
  'cancelled',
  'rejected'
);

-- Payment methods
CREATE TYPE payment_method AS ENUM ('wallet', 'upi', 'cash', 'card', 'udhaar');

-- Payment statuses
CREATE TYPE payment_status AS ENUM (
  'initiated',
  'pending_verification',
  'pending_cashier',
  'confirmed',
  'approved',
  'failed',
  'rejected',
  'refunded'
);

-- KOT statuses
CREATE TYPE kot_status AS ENUM ('new', 'accepted', 'preparing', 'ready', 'served', 'cancelled');

-- Order item statuses
CREATE TYPE item_status AS ENUM ('pending', 'preparing', 'ready', 'served', 'cancelled');

-- Wallet transaction types
CREATE TYPE wallet_txn_type AS ENUM ('topup', 'debit', 'refund');

-- Udhaar ledger entry types
CREATE TYPE udhaar_entry_type AS ENUM ('debit', 'repayment');
