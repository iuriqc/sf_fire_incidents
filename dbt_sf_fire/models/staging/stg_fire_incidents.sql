{{
  config(
    materialized='view'
  )
}}

SELECT
    id,
    incident_number,
    CAST(incident_date AS TIMESTAMP) as incident_date,
    address,
    city,
    zipcode,
    battalion,
    supervisor_district,
    neighborhood_district,
    station_area,
    primary_situation,
    estimated_property_loss::decimal(18,2) as estimated_property_loss,
    estimated_contents_loss::decimal(18,2) as estimated_contents_loss,
    fire_fatalities::integer as fire_fatalities,
    fire_injuries::integer as fire_injuries,
    civilian_fatalities::integer as civilian_fatalities,
    civilian_injuries::integer as civilian_injuries,
    number_of_alarms::integer as number_of_alarms,
    DATE_TRUNC('day', CAST(incident_date AS TIMESTAMP)) as incident_date_day,
    DATE_TRUNC('month', CAST(incident_date AS TIMESTAMP)) as incident_date_month,
    data_loaded_at
FROM
    {{ ref('load_fire_incidents') }}