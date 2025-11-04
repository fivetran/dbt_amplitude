with base as (

    select * 
    from {{ ref('stg_amplitude__event_type_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_amplitude__event_type_tmp')),
                staging_columns=get_event_type_columns()
            )
        }}
        {{ amplitude.apply_source_relation() }}
    from base
),

final as (

    select
        source_relation,
        id as event_type_id,
        name as event_type_name,
        project_name,
        display,
        totals,
        totals_delta,
        value,
        flow_hidden as is_flow_hidden,
        hidden as is_hidden,
        in_waitroom as is_in_waitroom,
        non_active as is_non_active,
        autohidden as is_autohidden,
        deleted as is_deleted,
        timeline_hidden as is_timeline_hidden,
        waitroom_approved as is_waitroom_approved,
        _fivetran_deleted,
        _fivetran_synced
    from fields
),

surrogate as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['source_relation','event_type_id','project_name']) }} as unique_event_type_id
    from final
)

select *
from surrogate