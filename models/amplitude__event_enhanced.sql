with event_data as (

    select * 
    from {{ var('event') }}
),

event_type as (

    select * 
    from {{ var('event_type') }}
)

select
    ed.event_id,
    et.event_type_id,
    et.in_waitroom,
    et.event_type_name,
    et.project_name,
    et.totals,
    et.value,
    {% if var('event_properties_to_pivot') %},
    {{ fivetran_utils.pivot_json_extract(string = 'event_properties', list_of_properties = var('event_properties_to_pivot')) }}
    {% endif %}
    
    from event_data ed 
    left join event_type et
    on ed.event_type_id = et.event_type_id