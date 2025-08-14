{% macro get_event_type_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "autohidden", "datatype": "boolean"},
    {"name": "deleted", "datatype": "boolean"},
    {"name": "display", "datatype": dbt.type_string()},
    {"name": "flow_hidden", "datatype": "boolean"},
    {"name": "hidden", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "in_waitroom", "datatype": "boolean"},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "non_active", "datatype": "boolean"},
    {"name": "project_name", "datatype": dbt.type_string()},
    {"name": "timeline_hidden", "datatype": "boolean"},
    {"name": "totals", "datatype": dbt.type_int()},
    {"name": "totals_delta", "datatype": dbt.type_int()},
    {"name": "value", "datatype": dbt.type_string()},
    {"name": "waitroom_approved", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
