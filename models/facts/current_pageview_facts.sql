{{ config(
   materialized='table', 
)}}

WITH current_pageview_facts AS (

    SELECT DATE_TRUNC('hour', pe.pageview_datetime::TIMESTAMP) AS pageview_hour,
           DATE_TRUNC('day', pe.pageview_datetime::TIMESTAMP) AS pageview_day,
           DATE_TRUNC('week', pe.pageview_datetime::TIMESTAMP) AS pageview_week,
           DATE_TRUNC('year', pe.pageview_datetime::TIMESTAMP) AS pageview_year,
           ups.postcode,
           COUNT(*) AS pageview_count
      FROM {{ source( env_var('DBT_SOURCE'), 'pageviews_extract') }} AS pe
      JOIN {{ source( env_var('DBT_SOURCE'), 'users_postcodes_staging') }} AS ups 
        ON pe.user_id = ups.id 
       AND ups.dbt_valid_to IS NULL        
  GROUP BY DATE_TRUNC('hour', pe.pageview_datetime::TIMESTAMP),
           DATE_TRUNC('day', pe.pageview_datetime::TIMESTAMP),
           DATE_TRUNC('week', pe.pageview_datetime::TIMESTAMP),
           DATE_TRUNC('year', pe.pageview_datetime::TIMESTAMP),
           ups.postcode    
)

    SELECT {{ dbt_utils.surrogate_key(
             'cpf.pageview_hour',
             'cpf.postcode'
           ) }} as fact_id,
           cpf.pageview_hour,
           cpf.pageview_day,
           cpf.pageview_week,
           cpf.pageview_year,
           cpf.postcode,
           cpf.pageview_count
      FROM current_pageview_facts AS cpf