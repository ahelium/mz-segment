{{ config(materialized='source') }}
--- note: replace UPSTASH_BROKER with your upstash broker url!
--- note: if developing locally, replace username and password with strings provided w/in upstash
CREATE SOURCE IF NOT EXISTS {{ this }}
  FROM KAFKA BROKER 'UPSTASH_BROKER' TOPIC 'web_production'
  WITH (
      security_protocol = 'SASL_SSL',
      sasl_mechanisms = 'SCRAM-SHA-256',
      sasl_username = SECRET segment_upstash_user,
      sasl_password = SECRET segment_upstash_pw
  )
FORMAT BYTES;