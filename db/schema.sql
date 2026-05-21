-- PinchDrop Database Schema
-- Version: 2026.05.21
-- Description: Optimized PostgreSQL schema for the PinchDrop Catalog SKU profiles.

BEGIN;

-- Enable UUID extension if UUIDs are preferred for primary keys,
-- but we will use standard BIGSERIAL for space-efficiency and sequential sorting.
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. RECIPES & SPICE KITS TABLE
CREATE TABLE IF NOT EXISTS recipes (
    id BIGSERIAL PRIMARY KEY,
    recipe_name VARCHAR(255) NOT NULL UNIQUE,
    origin_region VARCHAR(100) NOT NULL,
    key_spices VARCHAR(100)[] NOT NULL, -- Stored as an array for efficient indexing and searching
    prep_time_minutes INTEGER NOT NULL CHECK (prep_time_minutes > 0), -- Prep + cook time in minutes
    estimated_unit_cost_cents INTEGER NOT NULL CHECK (estimated_unit_cost_cents >= 0), -- Stored in cents to avoid floating point errors
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. INDEXES FOR PERFORMANCE OPTIMIZATION
-- Index active status for high-traffic public catalog queries
CREATE INDEX IF NOT EXISTS idx_recipes_active 
ON recipes(active) 
WHERE active = TRUE;

-- GIN Index on key_spices array for ultra-fast matching of recipes by specific spices
CREATE INDEX IF NOT EXISTS idx_recipes_key_spices 
ON recipes USING gin(key_spices);

-- B-Tree Index on origin_region for fast filtering by geographical area
CREATE INDEX IF NOT EXISTS idx_recipes_origin_region 
ON recipes(origin_region);

-- Compound Index for sorting by preparation time on active recipes
CREATE INDEX IF NOT EXISTS idx_recipes_active_prep_time 
ON recipes(active, prep_time_minutes ASC);

-- 3. AUTOMATIC UPDATED_AT TRIGGER
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_recipes_updated_at
    BEFORE UPDATE ON recipes
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

COMMIT;
