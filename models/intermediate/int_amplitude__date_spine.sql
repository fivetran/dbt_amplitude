{{
    config(
        materialized='incremental',
        unique_key='date_spine_unique_key',
        partition_by={"field": "event_day", "data_type": "date"} if target.type not in ('spark','databricks') else ['event_day'],
        incremental_strategy = 'merge',
        file_format = 'delta' 
        )
}}

with event_data as (

    select * 
    from {{ ref('amplitude__event_enhanced') }}
),

-- create end_date_adjust variable
{% if execute %}
{% set end_date_query %}
    -- select one day past current day
    select  {{ dbt_utils.dateadd("day", 1, dbt_utils.date_trunc("day", dbt_utils.current_timestamp())) }}
{% endset %}

{% set end_date = run_query(end_date_query).columns[0][0]|string %}

        {% set end_date_adjust =  end_date[0:10]  %}

{% endif %}

spine as (

    select * 

    from (
        {{ dbt_utils.date_spine(
            datepart = "day", 
            start_date =  "cast('" ~ var('date_range_start',  '2020-01-01') ~ "' as date)", 
            end_date = "cast('" ~ var('date_range_end',  end_date_adjust) ~ "' as date)" 
            )
        }} 
    ) as spine

    {% if is_incremental() %} 
    
    where date_day > ( select max(date_day) from {{ this }} )
    
    {% endif %}
    
),

date_spine as (


    select
        distinct event_data.event_type,
        cast(spine.date_day as date) as event_day,
        {{ dbt_utils.surrogate_key(['spine.date_day','event_data.event_type']) }} as date_spine_unique_key

    from spine 
    join event_data
        on spine.date_day >= event_data.event_day -- each event_type will have a record for every day since their first day
    
)

select * 
from date_spine

