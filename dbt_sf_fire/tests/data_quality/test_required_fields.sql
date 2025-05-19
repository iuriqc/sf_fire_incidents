-- Ensure critical fields are never null
SELECT
  incident_number,
  incident_date,
  battalion
FROM {{ ref('stg_fire_incidents') }}
WHERE
  incident_number IS NULL
  OR incident_date IS NULL
  OR battalion IS NULL