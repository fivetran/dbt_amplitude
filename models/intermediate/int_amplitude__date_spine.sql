{{
    config(
        materialized='incremental',
        unique_key='date_spine_unique_key',
        partition_by={
            "field": "event_day",
            "data_type": "date"
        }
    )
}}

with event_data as (

    select * 
    from {{ ref('amplitude__event_enhanced') }}
),

spine as (

    select * 

    from (
        {{ dbt_utils.date_spine(
            datepart = "day", 
            start_date =  "cast('" ~ var('date_range_start',  '2010-01-01') ~ "' as date)", 
            end_date = "cast('" ~ var('date_range_end',  dbt_utils.dateadd("day", 1, dbt_utils.date_trunc('day', dbt_utils.current_timestamp())) ) ~ "' as date)" 
            )
        }} 
    ) as spine

    {% if is_incremental() %} 
    
    where date_day > coalesce(( select max(date_day) from {{ this }} ), '2010-01-01') -- every user-event_type will have the same last day
    
    {% endif %}
    
),

date_spine as (


    select
        cast(spine.date_day as date) as event_day,
        event_data.unique_event_id,
        event_data.amplitude_user_id,
        event_data.event_type,
        {{ dbt_utils.surrogate_key(['spine.date_day', 'event_data.unique_event_id']) }} as date_spine_unique_key

    from spine 
    join event_data
        on spine.date_day >= event_data.event_day -- each user-event_type will a record for every day since their first day

    group by 1,2,3,4,5
    
)

select * from date_spine

