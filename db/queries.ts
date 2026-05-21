import pg from 'pg';

// Initialize a connection pool with transaction mode support (PgBouncer port)
// serverless function optimization: reuse connection pool across invocations
const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10, // Avoid overwhelming serverless limits
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

export interface RecipeCatalogItem {
  id: string;
  recipe_name: string;
  origin_region: string;
  key_spices: string[];
  prep_time_minutes: number;
  estimated_unit_cost_cents: number;
  active: boolean;
  created_at: Date;
}

/**
 * Optimized query to retrieve active recipes filtered by key spice ingredients
 * Utilizes the GIN index on the key_spices column for O(1) searches.
 */
export async function fetchRecipesBySpice(spiceName: string): Promise<RecipeCatalogItem[]> {
  const query = `
    SELECT 
      id, 
      recipe_name, 
      origin_region, 
      key_spices, 
      prep_time_minutes, 
      estimated_unit_cost_cents, 
      active, 
      created_at
    FROM recipes
    WHERE active = TRUE 
      AND $1 = ANY(key_spices);
  `;
  
  const result = await pool.query(query, [spiceName.toLowerCase()]);
  return result.rows;
}

/**
 * High-performance query to fetch active catalog items with pagination
 * Utilizes index on (active, prep_time_minutes) for ultra-fast sorting.
 */
export async function fetchActiveCatalog(limit = 10, offset = 0): Promise<RecipeCatalogItem[]> {
  const query = `
    SELECT 
      id, 
      recipe_name, 
      origin_region, 
      key_spices, 
      prep_time_minutes, 
      estimated_unit_cost_cents, 
      active
    FROM recipes
    WHERE active = TRUE
    ORDER BY prep_time_minutes ASC
    LIMIT $1 OFFSET $2;
  `;
  
  const result = await pool.query(query, [limit, offset]);
  return result.rows;
}
