with event_data as (

    select * 
    from {{ var('event') }}
),

session_data as (

    select 

    session_id,
    user_id,
    count(event_id) as events_per_session,
    min(event_time) as session_started_at,
    max(event_time) as session_ended_at,
    max(event_time) - min(event_time) as session_length

    from event_data
    group by session_id, user_id, event_time
)

select 
    distinct session_id,
    user_id,
    events_per_session,
    session_started_at,
    session_ended_at,
    session_length,
    row_number() over (partition by user_id order by session_started_at) as session_number
    -- case when event_time = session_started_at then 1 else 0 end as is_new_session
from session_data
