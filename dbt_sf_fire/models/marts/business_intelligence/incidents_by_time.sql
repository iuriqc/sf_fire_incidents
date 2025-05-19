{{
  config(
    materialized='table',
    partition_by={
      "field": "incident_date_month",
      "data_type": "date"
    }
  )
}}

WITH monthly_metrics AS (
  SELECT
    DATE_TRUNC('month', incident_date) AS incident_date_month,
    primary_situation,
    COUNT(*) AS incident_count,
    SUM(estimated_property_loss) AS total_property_loss,
    SUM(fire_fatalities + civilian_fatalities) AS total_fatalities
  FROM {{ ref('fact_fire_incidents') }}
  GROUP BY 1, 2
)

SELECT
  incident_date_month,
  primary_situation,
  incident_count,
  total_property_loss,
  total_fatalities,
  -- Year-over-year calculations
  LAG(incident_count, 12) OVER (PARTITION BY primary_situation ORDER BY incident_date_month) AS incident_count_prev_year,
  total_property_loss - LAG(total_property_loss, 12) OVER (PARTITION BY primary_situation ORDER BY incident_date_month) AS property_loss_yoy_change
FROM monthly_metrics
ORDER BY incident_date_month DESC