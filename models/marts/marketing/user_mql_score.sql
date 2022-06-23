{{ config(materialized='materializedview') }}

SELECT
    email,
    sum(mql_score) AS mql_score,
    jsonb_agg(mql_events.event_name) AS mql_events,
    max(last_event_received_at) AS last_event_received_at
FROM {{ ref('user_mql_events') }} mql_events
JOIN {{ ref('mql_score') }} mql_score ON mql_events.event_name = mql_score.event_name
GROUP BY email
