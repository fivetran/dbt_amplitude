-- If using user_ids, this model will be included, otherwise it will not.
{% if var('amplitude__using_user_id', True) %}

with event_enhanced as (

    select * 
    from {{ ref('amplitude__event_enhanced') }}
),

session_data as (

    select *
    from {{ ref('amplitude__sessions') }}
)

select
    event_enhanced.user_id,
    count(distinct event_enhanced.unique_event_id) as total_events_per_user,
    count(distinct session_data.unique_session_id) as total_sessions_per_user,
    avg(session_data.session_length) as average_session_length,
    avg(session_data.minutes_in_between_sessions) as average_minutes_in_between_sessions

from event_enhanced
left join session_data
    on event_enhanced.unique_session_id = session_data.unique_session_id
where event_enhanced.user_id is not null
group by 1

{% endif %}