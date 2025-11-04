{{
    config(
        materialized='incremental' if is_incremental_compatible() else 'table',
        unique_key='unique_session_id',
        partition_by={"field": "session_started_at_day", "data_type": "date"} if target.type not in ('spark','databricks') else ['session_started_at_day'],
        cluster_by='session_started_at_day',
        incremental_strategy = 'insert_overwrite' if target.type in ('bigquery', 'databricks', 'spark') else 'delete+insert',
        file_format = 'delta'
        )
}}

with event_data_raw as (

    select events.*
    from {{ ref('stg_amplitude__event') }} as events

    {% if is_incremental() %}
    where event_day >= {{ amplitude.amplitude_lookback(from_date='max(session_started_at_day)', datepart='day', interval=var('lookback_window', 7)) }}
    {% endif %}
),

-- deduplicate
event_data as (

    select *
    from (
        select
            *,
            case when _insert_id is not null
                then row_number() over (partition by _insert_id {{ amplitude.partition_by_source_relation() }} order by client_upload_time desc)
                else row_number() over (partition by event_id, device_id, client_event_time, amplitude_user_id {{ amplitude.partition_by_source_relation() }} order by client_upload_time desc)
            end as nth_event_record

        from event_data_raw
        ) as duplicates
    where nth_event_record = 1
),

session_agg as (

    select
        source_relation,
        unique_session_id,
        user_id,
        count(event_id) as events_per_session,
        min(event_time) as session_started_at,
        max(event_time) as session_ended_at,
        {{ dbt.datediff('min(event_time)', 'max(event_time)', 'second') }} / 60 as session_length_in_minutes
    from event_data
    {{ dbt_utils.group_by(3) }}
),

session_ranking as (

    select
        source_relation,
        unique_session_id,
        user_id,
        events_per_session,
        session_started_at,
        session_ended_at,
        session_length_in_minutes,
        cast({{ dbt.date_trunc('day', 'session_started_at') }} as date) as session_started_at_day,
        cast({{ dbt.date_trunc('day', 'session_ended_at') }} as date) as session_ended_at_day,
        case
            when user_id is not null then row_number() over (partition by user_id {{ amplitude.partition_by_source_relation() }} order by session_started_at)
            else null
        end as user_session_number
    from session_agg
),

session_lag as (
    select
        *,
        -- determine prior sessions' end time, then in the following cte calculate the difference between current session's start time and last session's end time to determine the time in between sessions
        case
            when user_id is not null then lag(session_ended_at,1) over (partition by user_id {{ amplitude.partition_by_source_relation() }} order by session_ended_at)
            else null
        end as last_session_ended_at,
        case
            when user_id is not null then lag(session_ended_at_day,1) over (partition by user_id {{ amplitude.partition_by_source_relation() }} order by session_ended_at_day)
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
        when user_id is not null then {{ dbt.datediff('last_session_ended_at', 'session_started_at', 'second') }} / 60
        else null
    end as minutes_in_between_sessions
from session_lag