WITH source AS (

    SELECT * FROM {{ source('segment','cloud_production') }}

),

converted AS (

    SELECT cast(convert_from(data, 'utf8') AS jsonb) AS data FROM source
)

SELECT
    data->>'userId' AS user_id,
    data->>'anonymousId' AS anonymous_id,
    data->>'type' AS event_type,
    REPLACE(LOWER(data->>'event'), ' ', '_') AS event_name,
    data->>'properties' AS event_properties,
    (data->>'receivedAt')::timestamptz AS received_at
FROM converted
