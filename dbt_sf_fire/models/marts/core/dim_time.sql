{{
  config(
    materialized='table',
    unique_key='date_id'
  )
}}

WITH date_spine AS (
  SELECT '2000-01-01'::date + (a.n + b.n*1000) AS date_id
  FROM 
    (SELECT row_number() OVER () - 1 AS n FROM stl_scan LIMIT 1000) a,
    (SELECT row_number() OVER () - 1 AS n FROM stl_scan LIMIT 12) b
  WHERE '2000-01-01'::date + (a.n + b.n*1000) <= '2030-12-31'::date
  ORDER BY date_id
)

SELECT
  date_id,
  EXTRACT(YEAR FROM date_id) AS year,
  EXTRACT(QUARTER FROM date_id) AS quarter,
  EXTRACT(MONTH FROM date_id) AS month,
  EXTRACT(DAY FROM date_id) AS day,
  EXTRACT(DOW FROM date_id) AS day_of_week,
  EXTRACT(DOY FROM date_id) AS day_of_year,
  CASE 
    WHEN EXTRACT(DOW FROM date_id) IN (0, 6) THEN 'Weekend'
    ELSE 'Weekday'
  END AS is_weekend,
  TO_CHAR(date_id, 'Month') AS month_name,
  TO_CHAR(date_id, 'Day') AS day_name,
  CASE
    WHEN EXTRACT(MONTH FROM date_id) IN (12, 1, 2) THEN 'Winter'
    WHEN EXTRACT(MONTH FROM date_id) IN (3, 4, 5) THEN 'Spring'
    WHEN EXTRACT(MONTH FROM date_id) IN (6, 7, 8) THEN 'Summer'
    ELSE 'Fall'
  END AS season
FROM date_spine