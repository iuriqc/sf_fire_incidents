SELECT
    incident_number,
    incident_date
FROM
    {{ ref('stg_fire_incidents') }}
WHERE
    incident_date > CURRENT_DATE
    OR incident_date < '2000-01-01'