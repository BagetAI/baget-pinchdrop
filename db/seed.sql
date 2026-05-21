-- PinchDrop Database Initial Seed Data
-- Version: 2026.05.21
-- Description: Population of the initial 3 launch recipes and secondary expansion catalog SKUs.

INSERT INTO recipes (
    recipe_name, 
    origin_region, 
    key_spices, 
    prep_time_minutes, 
    estimated_unit_cost_cents, 
    active
) VALUES 
(
    'Thai Green Curry', 
    'Southeast Asia', 
    ARRAY['lemongrass', 'galangal', 'kaffir lime leaves', 'green bird''s eye chili', 'coriander root'], 
    30, 
    35, -- $0.35 raw spice cost per kit
    TRUE
),
(
    'Moroccan Tagine', 
    'North Africa', 
    ARRAY['ras el hanout', 'ceylon cinnamon', 'ground ginger', 'turmeric', 'sweet paprika', 'cumin'], 
    45, 
    38, -- $0.38 raw spice cost per kit
    TRUE
),
(
    'Szechuan Mapo Tofu', 
    'East Asia', 
    ARRAY['szechuan peppercorn', 'gochugaru', 'star anise', 'cassia cinnamon', 'fennel seed'], 
    25, 
    32, -- $0.32 raw spice cost per kit
    TRUE
),
(
    'Levantine Kofta Spices', 
    'Middle East', 
    ARRAY['allspice', 'ground sumac', 'roasted cumin', 'coriander', 'nutmeg'], 
    35, 
    30, -- $0.30 raw spice cost per kit
    TRUE
),
(
    'Indian Butter Chicken (Makhani)', 
    'South Asia', 
    ARRAY['kasuri methi', 'kashmiri chili', 'green cardamom', 'garam masala', 'mace'], 
    40, 
    36, -- $0.36 raw spice cost per kit
    TRUE
)
ON CONFLICT (recipe_name) DO UPDATE 
SET 
    origin_region = EXCLUDED.origin_region,
    key_spices = EXCLUDED.key_spices,
    prep_time_minutes = EXCLUDED.prep_time_minutes,
    estimated_unit_cost_cents = EXCLUDED.estimated_unit_cost_cents,
    active = EXCLUDED.active;
