{{
    config(
        materialized='incremental' if is_incremental_compatible() else 'table',
        unique_key='daily_unique_key',
        partition_by={"field": "event_day", "data_type": "date"} if target.type not in ('spark','databricks') else ['event_day'],
        cluster_by='event_day',
        incremental_strategy = 'insert_overwrite' if target.type in ('bigquery', 'databricks', 'spark') else 'delete+insert',
        file_format = 'delta' 
    )
}}

with event_enhanced as (

    select * 
    from {{ ref('amplitude__event_enhanced') }}
),

date_spine as (

    select distinct 
        event_enhanced.source_relation,
        event_enhanced.event_type,
        spine.date_day as event_day
    from {{ ref('int_amplitude__date_spine') }} as spine
    join event_enhanced -- this join limits the incremental run
        on spine.date_day >= event_enhanced.event_day -- each event_type will have a record for every day since their first day

    {% if is_incremental() %}
    where spine.date_day >= {{ amplitude.amplitude_lookback(from_date='max(event_day)', datepart = 'day', interval=var('lookback_window', 7)) }}
    {% endif %}
), 

agg_event_data as (

    select
        source_relation,
        event_day,
        event_type,
        count(distinct unique_event_id) as number_events,
        count(distinct unique_session_id) as number_sessions,
        count(distinct amplitude_user_id) as number_users,
        count(distinct
                (case when cast( {{ dbt.date_trunc('day', 'user_creation_time') }} as date) = event_day
            then amplitude_user_id end)) as number_new_users
    from event_enhanced
    group by 1,2,3
),

final as (
    select
        date_spine.source_relation,
        date_spine.event_day,
        date_spine.event_type,
        coalesce(agg_event_data.number_events, 0) as number_events,
        coalesce(agg_event_data.number_sessions, 0) as number_sessions,
        coalesce(agg_event_data.number_users, 0) as number_users,
        coalesce(agg_event_data.number_new_users, 0) as number_new_users,
        {{ dbt_utils.generate_surrogate_key(['date_spine.source_relation', 'date_spine.event_day', 'date_spine.event_type']) }} as daily_unique_key
    from date_spine
    left join agg_event_data
        on date_spine.source_relation = agg_event_data.source_relation
        and date_spine.event_day = agg_event_data.event_day
        and date_spine.event_type = agg_event_data.event_type
)

select *
from final