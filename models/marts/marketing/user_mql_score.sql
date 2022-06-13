{{ config(materialized='materializedview') }}

SELECT
    email,
    sum(mql_score) AS mql_score,
    jsonb_agg(mql_events.event_name) AS mql_events
FROM {{ ref('user_mql_events') }} mql_events
JOIN {{ ref('mql_score') }} mql_score AS mql_events.event_name = mql_score.event_name
GROUP BY email
