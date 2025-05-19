-- Verify that incident counts match between fact and staging
WITH fact_counts AS (
  SELECT COUNT(DISTINCT incident_number) AS fact_count FROM {{ ref('fact_fire_incidents') }}
),
staging_counts AS (
  SELECT COUNT(DISTINCT incident_number) AS staging_count FROM {{ ref('stg_fire_incidents') }}
)

SELECT
  fact_count,
  staging_count,
  fact_count - staging_count AS difference
FROM fact_counts, staging_counts
WHERE fact_count != staging_count