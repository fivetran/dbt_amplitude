--  funnel, retention 
--  with a summary of metrics such as total events, sessions, returning vs new users. May use an hour grain because of sessions being at 30 min default, this to be explored

with event_enhanced as (

    select * 
    from {{ ref('amplitude__event_enhanced') }}
),

session_data as (

    select *
    from {{ ref('amplitude__sessions') }}
)

select
    distinct event_day,
    count(distinct unique_event_id) as number_events,
    count(distinct unique_session_id) as number_sessions,
    case when session_data.is_first_user_session = 1 then count(distinct amplitude_user_id) else 0 end as number_new_users 

from event_enhanced
left join session_data
    on event_enhanced.unique_session_id = session_data.unique_session_id
group by 1