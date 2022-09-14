with event_enhanced as (

    select * 
    from {{ ref('amplitude__event_enhanced') }}
),

session_data as (

    select *
    from {{ ref('amplitude__sessions') }}
)

select
    ee.user_id,
    ee.user_creation_time,
    case when sd.is_first_user_session = '1' then sd.session_id else null end as first_user_session

-- total_events_per_user
-- total_sessions_peruser
-- average_session_length
-- average_time_in_between_sessions

from event_enhanced ee
left join session_data sd
    on ee.session_id = sd.session_id
where user_id is not null
