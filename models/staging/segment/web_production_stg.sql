WITH source AS (

    SELECT * FROM {{ source('segment','web_production') }}

),

converted AS (

    SELECT cast(convert_from(data, 'utf8') AS jsonb) AS data FROM source
),

renamed as (

    SELECT
        data->>'userId' AS user_id,
        data->>'anonymousId' AS anonymous_id,
        data->>'type' AS event_type,
        data->>'event' AS event,
        data->>'properties' AS event_properties,
        (data->>'received_at')::double AS received_at
    FROM converted
)

SELECT *,
       REPLACE(LOWER(event), ' ', '_') AS event_name,
       to_timestamp(received_at) AS received_at_ts
FROM renamed
