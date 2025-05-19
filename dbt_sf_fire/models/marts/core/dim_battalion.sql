{{
  config(
    materialized='table',
    unique_key='battalion_code',
    sort='battalion_code',
    dist='even'
  )
}}

WITH battalion_stats AS (
    SELECT 
        battalion AS battalion_code,
        MAX(city) AS city,  -- Using MAX to get one city per battalion
        COUNT(DISTINCT incident_number) AS total_incidents
    FROM {{ ref('stg_fire_incidents') }}
    WHERE battalion IS NOT NULL
    GROUP BY battalion
)

SELECT
    battalion_code,
    city,
    total_incidents
FROM battalion_stats
ORDER BY battalion_code