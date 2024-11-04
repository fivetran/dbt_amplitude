{{ config(materialized='ephemeral') }}

with spine as (
    {%- set last_date_query %}
        select 
            cast({{ dbt.dateadd("day", 1, dbt.current_timestamp()) }} as date) as max_date
    {% endset -%}

    {%- set last_date = dbt_utils.get_single_value(last_date_query) %}

    select
        cast(spine.date_day as date) as date_day
    from (
        {{ dbt_utils.date_spine(
            datepart = "day", 
            start_date =  "cast('" ~ var('amplitude__date_range_start',  '2020-01-01') ~ "' as date)",
            end_date = "cast('" ~ var('amplitude__date_range_end', last_date) ~ "' as date)" 
            )
        }} 
    ) as spine
)

select * 
from spine