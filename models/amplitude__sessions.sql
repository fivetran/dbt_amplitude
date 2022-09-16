{{
    config(
        materialized='incremental',
        unique_key='session_id',
        partition_by={
            "field": "session_started_at_day",
            "data_type": "date"
        }
    )
}}

with event_data as (

    select *
    from {{ var('event') }}
),

session_agg as (

    select 
        distinct session_id,
        count(event_id) as events_per_session,
        min(event_time) as session_started_at,
        max(event_time) as session_ended_at,
        max(event_time) - min(event_time) as session_length,
    from event_data
    group by session_id
),

session_number as (
    select
        distinct sa.session_id,
        ed.user_id,
        sa.events_per_session,
        sa.session_started_at,
        sa.session_ended_at,
        sa.session_length,
        {{ dbt_utils.date_trunc('day', 'session_started_at') }} as session_started_at_day,
        case 
            when ed.user_id is not null then dense_rank() over (partition by ed.user_id order by sa.session_started_at, sa.session_id asc)  -- dense rank used here because of rows belonging to same session (though now that we've filtered for distinct sesions, this shouldn't matter)
            else null
        end as user_session_number
from session_agg sa
left join event_data ed
    on sa.session_id = ed.session_id
)

select 
    *,
    case
        when user_session_number = 1 then '1' 
        else '0' 
    end as is_first_user_session
from session_number