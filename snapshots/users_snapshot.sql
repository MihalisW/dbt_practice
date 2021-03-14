{% snapshot users_postcodes_staging %}

{{
    config(
      target_database= env_var('DBT_DBNAME'),
      target_schema= env_var('DBT_SCHEMA'),
      unique_key='id',

      strategy='check',
      check_cols=['postcode'],
    )
}}

SELECT id, postcode FROM {{ source( env_var('DBT_SOURCE'), 'users_extract') }} GROUP BY id, postcode

{% endsnapshot %}