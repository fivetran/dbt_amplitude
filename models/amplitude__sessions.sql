{{
    config(
        materialized='incremental',
        unique_key='session_id',
        partition_by={
            "field": "session_started_at_day",
            "data_type": "timestamp"
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
        user_id,
        count(event_id) as events_per_session,
        min(event_time) as session_started_at,
        max(event_time) as session_ended_at,
        max(event_time) - min(event_time) as session_length,

    from event_data
    group by session_id, user_id
),

session_ranking as (
    select 
        session_id,
        user_id,
        events_per_session,
        session_started_at,
        session_ended_at,
        session_length,
        {{ dbt_utils.date_trunc('day', 'session_started_at') }} as session_started_at_day,
        {{ dbt_utils.date_trunc('day', 'session_ended_at') }} as session_ended_at_day,
        case 
            when user_id is not null then row_number() over (partition by user_id order by session_started_at) 
            else null
        end as user_session_number
from session_agg
),

session_lag as (
    select
        *, 
        -- have another column that says the prior sessions' end time, then in the next cte calculate the different between current session start time and last session end time
        case 
            when user_id is not null then lag(session_ended_at,1) over (partition by user_id order by session_ended_at) 
            else null
        end as last_session_ended_at,
        case 
            when user_id is not null then lag(session_ended_at_day,1) over (partition by user_id order by session_ended_at_day) 
            else null
        end as last_session_ended_at_day
from session_ranking
)

select 
    *,
    case
        when user_session_number = 1 then '1' 
        else '0' 
    end as is_first_user_session,
    case
        when user_id is not null then (session_started_at - last_session_ended_at)
        else null
    end as time_in_between_sessions,
    case
        when user_id is not null then (session_started_at_day - last_session_ended_at_day)
        else null
    end as days_in_between_sessions,
from session_lag