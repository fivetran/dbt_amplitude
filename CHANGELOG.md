# dbt_amplitude v0.2.0

## 🚨 Breaking Changes 🚨:
[PR #4](https://github.com/fivetran/dbt_amplitude/pull/4) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- `dbt_utils.surrogate_key` has also been updated to `dbt_utils.generate_surrogate_key`. Since the method for creating surrogate keys differ, we suggest all users do a `full-refresh` for the most accurate data. For more information, please refer to dbt-utils [release notes](https://github.com/dbt-labs/dbt-utils/releases) for this update.
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

## Under the Hood
- Updated the metric attribute names to be in alignment with the current version of dbt metrics: `sql` -> `expression` and `type` -> `calculation_method`.
# dbt_amplitude v0.1.0
🎉 Initial Release 🎉
- This is the initial release of our Amplitude package. For more information refer to the [README](https://github.com/fivetran/dbt_amplitude/blob/main/README.md).
- This package outputs an enhanced events model, along with a daily performance, sessions, and enhanced user final model. 
- In addition, this package can be used in conjunction with the[ dbt metrics package](https://github.com/dbt-labs/dbt_metrics) and the [dbt product analytics package](https://github.com/mjirv/dbt_product_analytics) for further analysis. Information on configuration as well as example use cases are included in the [README](https://github.com/fivetran/dbt_amplitude/blob/main/README.md).

Currently the package supports Postgres, Redshift, BigQuery, Databricks and Snowflake. Additionally, this package is designed to work with dbt versions [">=1.0.0", "<2.0.0"].