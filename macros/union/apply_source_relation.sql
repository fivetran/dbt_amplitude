{% macro apply_source_relation() -%}

{{ adapter.dispatch('apply_source_relation', 'amplitude') () }}

{%- endmacro %}

{% macro default__apply_source_relation() -%}

{% if var('amplitude_sources', []) != [] %}
, _dbt_source_relation as source_relation
{% else %}
, '{{ var("amplitude_database", target.database) }}' || '.'|| '{{ var("amplitude_schema", "amplitude") }}' as source_relation
{% endif %}

{%- endmacro %}