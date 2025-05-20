{{
  config(
    materialized='incremental',
    unique_key='incident_number',
    incremental_strategy='merge'
  )
}}

SELECT
    i.incident_number,
    i.incident_date,
    i.incident_date_day,
    i.incident_date_month,
    d.date_id AS incident_date_key,
    b.battalion_code,
    di.district_code,
    i.primary_situation,
    ABS(i.estimated_property_loss) AS estimated_property_loss,
    ABS(i.estimated_contents_loss) AS estimated_contents_loss,
    i.fire_fatalities,
    i.fire_injuries,
    i.civilian_fatalities,
    i.civilian_injuries,
    i.number_of_alarms,
    i.data_loaded_at
FROM
    {{ ref('stg_fire_incidents') }} i
LEFT JOIN
    {{ ref('dim_battalion') }} b ON i.battalion = b.battalion_code
LEFT JOIN
    {{ ref('dim_district') }} di ON i.supervisor_district = di.district_code
LEFT JOIN
    {{ ref('dim_time') }} d ON DATE(i.incident_date) = DATE(d.date_id)

{% if is_incremental() %}
WHERE i.data_loaded_at > (SELECT MAX(data_loaded_at) FROM {{ this }})
{% endif %}