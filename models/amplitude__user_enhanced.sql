{{
    config(
        materialized='incremental',
        unique_key='user_id',
        partition_by={
            "field": " ",
            "data_type": "date"
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
    -- case when sd.is_first_user_session = '1' then sd.session_id else null end as first_user_session,
    -- count(distinct event_id) as total_events_per_user,
    -- count(distinct sd.session_id) as total_sessions_per_user,
    -- avg(session_length) as average_session_length
sd.session_id,
sd.session_ended_at,
lag(sd.session_ended_at,1) over (partition by ee.user_id order by sd.session_ended_at) as last_session_ended_at 

from event_enhanced ee
left join session_data sd
    on ee.session_id = sd.session_id
where user_id is not null
group by user_id, sd.session_id, sd.session_ended_at

{% endif %}