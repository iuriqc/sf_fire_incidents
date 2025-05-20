{{
  config(
    materialized='table',
    schema='raw'
  )
}}

{% set create_sql %}
CREATE TABLE IF NOT EXISTS {{ this }} (
    incident_number VARCHAR(50),
    exposure_number VARCHAR(50),
    id VARCHAR(50),
    address VARCHAR(255),
    incident_date VARCHAR(50),
    call_number VARCHAR(50),
    alarm_dttm VARCHAR(50),
    arrival_dttm VARCHAR(50),
    close_dttm VARCHAR(50),
    city VARCHAR(100),
    zipcode VARCHAR(10),
    battalion VARCHAR(10),
    station_area VARCHAR(10),
    box VARCHAR(20),
    suppression_units VARCHAR(50),
    suppression_personnel VARCHAR(50),
    ems_units VARCHAR(50),
    ems_personnel VARCHAR(50),
    other_units VARCHAR(50),
    other_personnel VARCHAR(50),
    fire_fatalities VARCHAR(50),
    fire_injuries VARCHAR(50),
    civilian_fatalities VARCHAR(50),
    civilian_injuries VARCHAR(50),
    number_of_alarms VARCHAR(50),
    primary_situation VARCHAR(100),
    mutual_aid VARCHAR(50),
    action_taken_primary VARCHAR(100),
    property_use VARCHAR(100),
    supervisor_district VARCHAR(10),
    neighborhood_district VARCHAR(100),
    point SUPER,
    data_as_of VARCHAR(50),
    data_loaded_at VARCHAR(50),
    action_taken_secondary VARCHAR(100),
    area_of_fire_origin VARCHAR(100),
    ignition_cause VARCHAR(100),
    ignition_factor_primary VARCHAR(100),
    heat_source VARCHAR(150),
    item_first_ignited VARCHAR(100),
    human_factors_associated_with_ignition VARCHAR(200),
    estimated_property_loss VARCHAR(50),
    detector_alerted_occupants VARCHAR(50),
    structure_type VARCHAR(100),
    no_flame_spread VARCHAR(50),
    detectors_present VARCHAR(50),
    detector_type VARCHAR(100),
    detector_operation VARCHAR(100),
    detector_effectiveness VARCHAR(100),
    automatic_extinguishing_system_present VARCHAR(50),
    estimated_contents_loss VARCHAR(50),
    structure_status VARCHAR(100),
    floor_of_fire_origin VARCHAR(50),
    automatic_extinguishing_sytem_type VARCHAR(100),
    automatic_extinguishing_sytem_perfomance VARCHAR(100),
    number_of_sprinkler_heads_operating VARCHAR(50),
    action_taken_other VARCHAR(100),
    detector_failure_reason VARCHAR(100),
    ignition_factor_secondary VARCHAR(100),
    automatic_extinguishing_sytem_failure_reason VARCHAR(100),
    fire_spread VARCHAR(100),
    number_of_floors_with_minimum_damage VARCHAR(50),
    number_of_floors_with_significant_damage VARCHAR(50),
    number_of_floors_with_heavy_damage VARCHAR(50),
    number_of_floors_with_extreme_damage VARCHAR(50),
    _processing_date DATE,
    first_unit_on_scene VARCHAR(50)
)
{% endset %}

{% do run_query(create_sql) %}

{% set copy_sql %}
COPY {{ this }}
FROM 's3://{{ env_var("S3_PATH") }}'
IAM_ROLE '{{ env_var("REDSHIFT_IAM_ROLE") }}'
FORMAT AS PARQUET SERIALIZETOJSON
{% endset %}

{% do run_query(copy_sql) %}

SELECT * FROM {{ this }}