{{
    config(
        materialized='incremental',
        unique_key='unique_session_id',
        partition_by={"field": "session_started_at_day", "data_type": "timestamp"} if target.type != 'spark' else ['session_started_at_day'],
        incremental_strategy = 'merge',
        file_format = 'delta'
        )
}}

with event_data_raw as (

    select *
    from {{ var('event') }}

    where 
    {% if is_incremental() %}
    
    -- look back
    event_time >= coalesce( ( select cast (  max({{ dbt_utils.date_trunc('day', 'event_time') }})  as {{ dbt_utils.type_timestamp() }} ) from {{ this }} ), '2020-01-01')

    {% else %}

    event_time >= {{ "'" ~ var('date_range_start', '2020-01-01') ~ "'"}}

    {% endif %}
),

-- deduplicate
event_data as (
    
    select * 
    from (

    select 
        *,
        row_number() over (partition by event_id, device_id, client_event_time order by client_upload_time desc) as nth_event_record

        from event_data_raw
    ) as duplicates
    where nth_event_record = 1

),

session_agg as (

    select
        unique_session_id,
        user_id,
        event_type,
        app,
        project_name,
        city,
        language,
        country,
        region,
        os_name,
        os_version,
        device_brand,
        device_carrier,
        device_family,
        device_model,
        device_type,
        platform,
        count(event_id) as events_per_session,
        min(event_time) as session_started_at,
        max(event_time) as session_ended_at,
        {{ dbt_utils.datediff('min(event_time)', 'max(event_time)', 'second') }} as session_length

    from event_data
    group by dbt_utils.group_by(10)
),

session_ranking as (
    select 
        unique_session_id,
        user_id,
        event_type,
        app,
        project_name,
        city,
        language,
        country,
        region,
        os_name,
        os_version,
        device_brand,
        device_carrier,
        device_family,
        device_model,
        device_type,
        platform,
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
        -- determine prior sessions' end time, then in the following cte calculate the different between current session start time and last session end time to determine the time in between sessions
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
        when user_session_number = 1 then 1
        else 0
    end as is_first_user_session,
    case
        when user_id is not null then {{ dbt_utils.datediff('last_session_ended_at', 'session_started_at', 'second') }} 
        else null
    end as seconds_in_between_sessions,
    case
        when user_id is not null then {{ dbt_utils.datediff('last_session_ended_at', 'session_started_at', 'second') }} / 60
        else null
    end as minutes_in_between_sessions,
    case
        when user_id is not null then {{ dbt_utils.datediff('last_session_ended_at_day', 'session_started_at_day', 'day') }}
        else null
    end as days_in_between_sessions
from session_lag