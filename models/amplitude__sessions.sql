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

session_number as (
    select 
        session_id,
        events_per_session,
        session_started_at,
        session_ended_at,
        session_length,
        case 
            when user_id is not null then row_number() over (partition by user_id order by session_started_at) 
            else null
        end as user_session_number
from session_agg
)

select 
    *,
    case
        when user_session_number = 1 then '1' 
        else '0' 
    end as is_first_user_session
from session_number