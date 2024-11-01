-- depends_on: {{ ref('amplitude__event_enhanced') }}
{{ config(materialized='ephemeral') }}

with spine as (
    {% if execute and flags.WHICH in ('run', 'build') %}
    {%- set first_date_query %}
        select 
            coalesce(
                min(cast(event_day as date)), 
                cast({{ dbt.dateadd("month", -1, "current_date") }} as date)
                ) as min_date
            from {{ ref('amplitude__event_enhanced') }} 
    {% endset -%}
    {%- set first_date = dbt_utils.get_single_value(first_date_query) %}
    
    {% else %} 
    {% set first_date = "2020-01-01" %}

    {% endif %}

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
            start_date =  "cast('" ~ var('amplitude__date_range_start',  first_date) ~ "' as date)", 
            end_date = "cast('" ~ var('amplitude__date_range_end', last_date) ~ "' as date)" 
            )
        }} 
    ) as spine
)

select * 
from spine