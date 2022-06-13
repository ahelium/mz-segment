{{ config(materialized='materializedview') }}

SELECT
    user_id AS email,
    event_name,
    count(user_id) AS event_cnt,
    max(received_at) AS last_event_received_at
FROM {{ ref('web_production_stg') }}
WHERE event_type = 'track'
GROUP BY 1,2

