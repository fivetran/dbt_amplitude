{{ config(materialized='ephemeral') }}

with spine as (
{% set end_date_query %}
    -- select one day past current day
    select cast({{ dbt.dateadd("day", 1, dbt.current_timestamp()) }} as date) as max_date
{% endset %}

{%- set end_date_adjust = dbt_utils.get_single_value(end_date_query) %}

    select
        cast(spine.date_day as date) as date_day
    from (
        {{ dbt_utils.date_spine(
            datepart = "day", 
            start_date =  "cast('" ~ var('amplitude__date_range_start',  '2020-01-01') ~ "' as date)",
            end_date = "cast('" ~ var('amplitude__date_range_end', end_date_adjust) ~ "' as date)" 
            )
        }} 
    ) as spine
)

select * 
from spine