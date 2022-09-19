{{
    config(
        materialized='incremental',
        unique_key='user_id',
        partition_by={
            "field": "event_day",
            "data_type": "timestamp"
        }
    )
}}

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
    ee.user_id,
    count(distinct ee.unique_event_id) as total_events_per_user,
    count(distinct sd.session_id) as total_sessions_per_user,
    avg(sd.session_length) as average_session_length,
    avg(sd.time_in_between_sessions) as average_time_in_between_sessions

from event_enhanced ee
left join session_data sd
    on ee.session_id = sd.session_id
where ee.user_id is not null
group by ee.user_id

{% endif %}