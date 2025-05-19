{{
  config(
    materialized='table',
    unique_key='district_code'
  )
}}

SELECT
    supervisor_district AS district_code,
    neighborhood_district AS neighborhood_district,
    COUNT(incident_number) AS total_incidents,
    AVG(estimated_property_loss) AS avg_property_loss
FROM
    {{ ref('stg_fire_incidents') }}
GROUP BY 1, 2