{{
    config(
        materialized='incremental',
        unique_key='unique_event_id',
        partition_by={"field": "event_day", "data_type": "timestamp"} if target.type != 'spark' else ['event_day'],
        incremental_strategy = 'merge',
        file_format = 'delta' 
        )
}}

with event_data as (

    select * 
    from {{ var('event') }}
),

event_type as (

    select * 
    from {{ var('event_type') }}
)

select
    event_data.unique_event_id,
    event_data.unique_session_id,
    event_data.event_id,
    event_data.event_type,
    event_data.event_time,
    {{ dbt_utils.date_trunc('day', 'event_time') }} as event_day,
    event_data.session_id,
    event_data.amplitude_id,
    event_data.app,
    event_data.project_name,
    event_data.version_name,
    event_data.client_event_time,
    event_data.client_upload_time,
    event_data.server_received_time,
    event_data.server_upload_time,
    event_data.city,
    event_data.country,
    event_data.region,
    event_data.data,
    event_data.location_lat,
    event_data.location_lng,
    event_data.device_brand,
    event_data.device_carrier,
    event_data.device_family,
    event_data.device_id,
    event_data.device_manufacturer,
    event_data.device_model,
    event_data.device_type,
    event_data.ip_address,
    event_data.os_name,
    event_data.os_version,
    event_data.platform,
    event_data.language,
    event_data.dma,
    event_data.schema,
    event_data.start_version,
    event_data.user_creation_time,
    row_number() over (partition by session_id order by event_time asc) as session_event_number,
    event_data.group_types,
    cast(event_data.user_id as {{ dbt_utils.type_string() }}) as user_id, 
    event_type.event_type_id,
    event_type.event_type_name,
    event_type.totals,
    event_type.value

    {% if var('event_properties_to_pivot') %},
    {{ fivetran_utils.pivot_json_extract(string = 'event_properties', list_of_properties = var('event_properties_to_pivot')) }}
    {% endif %}

    {% if var('group_properties_to_pivot') %},
    {{ fivetran_utils.pivot_json_extract(string = 'group_properties', list_of_properties = var('group_properties_to_pivot')) }}
    {% endif %}

    {% if var('user_properties_to_pivot') %},
    {{ fivetran_utils.pivot_json_extract(string = 'user_properties', list_of_properties = var('user_properties_to_pivot')) }}
    {% endif %}

    from event_data
    left join event_type
    on event_data.event_type_id = event_type.event_type_id