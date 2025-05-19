{{
  config(
    materialized='incremental',
    incremental_strategy='append'
  )
}}

SELECT
    d.district_code,
    d.neighborhood_district,
    EXTRACT(YEAR FROM f.incident_date) AS year,
    EXTRACT(MONTH FROM f.incident_date) AS month,
    COUNT(*) AS incident_count,
    SUM(f.estimated_property_loss) AS total_property_loss,
    SUM(f.fire_fatalities) AS total_fatalities
FROM
    {{ ref('fact_fire_incidents') }} f
JOIN
    {{ ref('dim_district') }} d ON f.district_code = d.district_code
GROUP BY 1, 2, 3, 4