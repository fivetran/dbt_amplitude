{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

{% set exclude_cols = var('consistency_test_exclude_metrics', []) %}

-- this test ensures the amplitude__user_enhanced end model matches the prior version
with prod as (
    select {{ dbt_utils.star(from=ref('amplitude__user_enhanced'), except=exclude_cols) }}
    from {{ target.schema }}_amplitude_prod.amplitude__user_enhanced
),

dev as (
    select {{ dbt_utils.star(from=ref('amplitude__user_enhanced'), except=exclude_cols) }}
    from {{ target.schema }}_amplitude_dev.amplitude__user_enhanced
), 

prod_not_in_dev as (
    -- rows from prod not found in dev
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    -- rows from dev not found in prod
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all -- union since we only care if rows are produced

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final