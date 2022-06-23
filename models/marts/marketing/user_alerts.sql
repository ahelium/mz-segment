{{ config(materialized='materializedview', tags='hightouch') }}

SELECT
    'mql_threshold_20' as alert_condition,
    jsonb_build_object('email', email) as alert_labels,
    mql_score as alert_value
FROM {{ ref('user_mql_score') }}
WHERE mql_score >= 20
