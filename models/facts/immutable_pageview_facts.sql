{{ config(materialized='incremental') }}

WITH immutable_pageview_facts AS (

    SELECT DATE_TRUNC('hour', pe.pageview_datetime::TIMESTAMP) AS pageview_hour,
           DATE_TRUNC('day', pe.pageview_datetime::TIMESTAMP) AS pageview_day,
           DATE_TRUNC('week', pe.pageview_datetime::TIMESTAMP) AS pageview_week,
           DATE_TRUNC('year', pe.pageview_datetime::TIMESTAMP) AS pageview_year,
           ups.postcode,
           COUNT(*) AS pageview_count
      FROM playground.pageviews_extract AS pe
      JOIN playground.users_postcodes_staging AS ups 
        ON pe.user_id = ups.id 
       AND (pe.pageview_datetime::TIMESTAMP >= ups.dbt_valid_from
                      AND pe.pageview_datetime::TIMESTAMP < COALESCE(ups.dbt_valid_to, CURRENT_TIMESTAMP))
  GROUP BY DATE_TRUNC('hour', pe.pageview_datetime::TIMESTAMP),
           DATE_TRUNC('day', pe.pageview_datetime::TIMESTAMP),
           DATE_TRUNC('week', pe.pageview_datetime::TIMESTAMP),
           DATE_TRUNC('year', pe.pageview_datetime::TIMESTAMP),
           ups.postcode    
)

,increment AS (
       SELECT MAX(pageview_hour) AS value_ FROM {{ this }}
)

    SELECT {{ dbt_utils.surrogate_key(
             'pageview_hour',
             'postcode'
           ) }} as fact_id,
           pageview_hour,
           pageview_day,
           pageview_week,
           pageview_year,
           postcode,
           pageview_count
      FROM immutable_pageview_facts
      {% if is_incremental() %} 
      WHERE pageview_hour > (SELECT value_ FROM increment)     
      {% endif %}        