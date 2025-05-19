{{
  config(
    materialized='incremental',
    partition_by={
      "field": "incident_date_month",
      "data_type": "date"
    },
    cluster_by = ["battalion_code"]
  )
}}

WITH battalion_stats AS (
  SELECT
    b.battalion_code,
    DATE_TRUNC('month', f.incident_date) AS incident_date_month,
    COUNT(*) AS incident_count,
    SUM(f.estimated_property_loss) AS total_property_loss,
    SUM(f.fire_fatalities + f.civilian_fatalities) AS total_fatalities,
    AVG(f.estimated_property_loss) AS avg_property_loss,
    COUNT(DISTINCT f.district_code) AS districts_served
  FROM {{ ref('fact_fire_incidents') }} f
  JOIN {{ ref('dim_battalion') }} b ON f.battalion_code = b.battalion_code
  GROUP BY 1, 2
),

battalion_rankings AS (
  SELECT
    *,
    RANK() OVER (PARTITION BY incident_date_month ORDER BY incident_count DESC) AS rank_by_volume,
    RANK() OVER (PARTITION BY incident_date_month ORDER BY total_property_loss DESC) AS rank_by_loss
  FROM battalion_stats
)

SELECT
  r.*
FROM battalion_rankings r

{% if is_incremental() %}
WHERE incident_date_month > (SELECT MAX(incident_date_month) FROM {{ this }})
{% endif %}