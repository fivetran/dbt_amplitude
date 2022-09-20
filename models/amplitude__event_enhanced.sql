{{
    config(
        materialized='incremental',
        unique_key='unique_event_id',
        partition_by={"field": "event_day", "data_type": "timestamp"} if target.type != 'spark' else ['event_day'],
        incremental_strategy='merge',
        file_format='delta'
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
    unique_event_id,
    ed.event_id,
    ed.event_type,
    ed.event_time,
    {{ dbt_utils.date_trunc('day', 'event_time') }} as event_day,
    ed.session_id,
    ed.amplitude_id,
    ed.app,
    ed.project_name,
    ed.version_name,
    ed.client_event_time,
    ed.client_upload_time,
    ed.server_received_time,
    ed.server_upload_time,
    ed.city,
    ed.country,
    ed.region,
    ed.data,
    ed.location_lat,
    ed.location_lng,
    ed.device_brand,
    ed.device_carrier,
    ed.device_family,
    ed.device_id,
    ed.device_manufacturer,
    ed.device_model,
    ed.device_type,
    ed.ip_address,
    ed.os_name,
    ed.os_version,
    ed.platform,
    ed.language,
    ed.dma,
    ed.schema,
    ed.start_version,
    ed.user_creation_time,
    row_number() over (partition by session_id order by event_time asc) as session_event_number,
    ed.group_types,
    cast(ed.user_id as {{ dbt_utils.type_string() }}) as user_id, 
    et.event_type_id,
    et.event_type_name,
    et.in_waitroom,
    et.totals,
    et.value

    {% if var('event_properties_to_pivot') %},
    {{ fivetran_utils.pivot_json_extract(string = 'event_properties', list_of_properties = var('event_properties_to_pivot')) }}
    {% endif %}

    {% if var('group_properties_to_pivot') %},
    {{ fivetran_utils.pivot_json_extract(string = 'group_properties', list_of_properties = var('group_properties_to_pivot')) }}
    {% endif %}

    {% if var('user_properties_to_pivot') %},
    {{ fivetran_utils.pivot_json_extract(string = 'user_properties', list_of_properties = var('user_properties_to_pivot')) }}
    {% endif %}

    from event_data ed 
    left join event_type et
    on ed.event_type_id = et.event_type_id