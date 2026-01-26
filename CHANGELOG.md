# dbt_amplitude v1.3.1-a1

[PR #33](https://github.com/fivetran/dbt_amplitude/pull/33) includes the following updates:

## Under the Hood
- Adjusts the data type for date variables in the `quickstart.yml` from `string` to `date`.

# dbt_amplitude v1.3.0

[PR #32](https://github.com/fivetran/dbt_amplitude/pull/32) includes the following updates:

## Documentation
- Updates README with standardized Fivetran formatting.

## Under the Hood
- In the `quickstart.yml` file:
  - Adds `supported_vars` for Quickstart UI customization.

# dbt_amplitude v1.2.0

[PR #31](https://github.com/fivetran/dbt_amplitude/pull/31) includes the following updates:

## Features
  - Increases the required dbt version upper limit to v3.0.0

# dbt_amplitude v1.1.0

[PR #30](https://github.com/fivetran/dbt_amplitude/pull/30) includes the following updates:

## Schema/Data Change (--full-refresh required after upgrading)
**9 total changes • 3 breaking changes**

| Data Model(s) | Change type | Old | New | Notes |
| ------------- | ----------- | ----| --- | ----- |
| All models | New column | | `source_relation` | Identifies the source connection when using multiple Amplitude connections |
| `amplitude__event_enhanced` | New column | | `source_relation` | **Breaking:** Incremental model requires `--full-refresh` after upgrading |
| `amplitude__sessions` | New column | | `source_relation` | **Breaking:** Incremental model requires `--full-refresh` after upgrading |
| `amplitude__daily_performance` | New column | | `source_relation` | **Breaking:** Incremental model requires `--full-refresh` after upgrading |
| `stg_amplitude__event` | Updated surrogate key | `unique_event_id` = `event_id` + `device_id` + `client_event_time` + `amplitude_user_id` | `unique_event_id` = `source_relation` + `event_id` + `device_id` + `client_event_time` + `amplitude_user_id` | Updated to include `source_relation` |
| `stg_amplitude__event` | Updated surrogate key | `unique_session_id` = `user_id` + `session_id` | `unique_session_id` = `source_relation` + `user_id` + `session_id` | Updated to include `source_relation` |
| `stg_amplitude__event_type` | Updated surrogate key | `unique_event_type_id` = `event_type_id` + `project_name` | `unique_event_type_id` = `source_relation` + `event_type_id` + `project_name` | Updated to include `source_relation` |
| `amplitude__event_enhanced` | Updated surrogate key | `unique_key` = `unique_event_id` + `unique_event_type_id` | `unique_key` = `source_relation` + `unique_event_id` + `unique_event_type_id` | Updated to include `source_relation` |
| `amplitude__daily_performance` | Updated surrogate key | `daily_unique_key` = `event_day` + `event_type` | `daily_unique_key` = `source_relation` + `event_day` + `event_type` | Updated to include `source_relation` |

## Feature Update
- **Union Data Functionality**: This release supports running the package on multiple Amplitude source connections. See the [README](https://github.com/fivetran/dbt_amplitude/tree/main?tab=readme-ov-file#step-3-define-database-and-schema-variables) for details on how to leverage this feature.

## Tests Update
- Removes uniqueness tests. The new unioning feature requires combination-of-column tests to consider the new `source_relation` column in addition to the existing primary key, but this is not supported across dbt versions.
 - These tests will be reintroduced once a version-agnostic solution is available.

# dbt_amplitude v1.0.0

[PR #29](https://github.com/fivetran/dbt_amplitude/pull/29) includes the following updates:

## Breaking Changes

### Source Package Consolidation
- Removed the dependency on the `fivetran/amplitude_source` package.
  - All functionality from the source package has been merged into this transformation package for improved maintainability and clarity.
  - If you reference `fivetran/amplitude_source` in your `packages.yml`, you must remove this dependency to avoid conflicts.
  - Any source overrides referencing the `fivetran/amplitude_source` package will also need to be removed or updated to reference this package.
  - Update any amplitude_source-scoped variables to be scoped to only under this package. See the [README](https://github.com/fivetran/dbt_amplitude/blob/main/README.md) for how to configure the build schema of staging models.
- As part of the consolidation, vars are no longer used to reference staging models, and only sources are represented by vars. Staging models are now referenced directly with `ref()` in downstream models.

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
- Moved `loaded_at_field: _fivetran_synced` under the `config:` block in `src_amplitude.yml`.

### Under the Hood
- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`.

# dbt_amplitude v0.7.0

[PR #25](https://github.com/fivetran/dbt_amplitude/pull/25) includes the following updates:

## Breaking Change for dbt Core < 1.9.6

> *Note: This is not relevant to Fivetran Quickstart users.*

Migrated `freshness` from a top-level source property to a source `config` in alignment with [recent updates](https://github.com/dbt-labs/dbt-core/issues/11506) from dbt Core ([Amplitude Source v0.5.0](https://github.com/fivetran/dbt_amplitude_source/releases/tag/v0.5.0)). This will resolve the following deprecation warning that users running dbt >= 1.9.6 may have received:

```
[WARNING]: Deprecated functionality
Found `freshness` as a top-level property of `amplitude` in file
`models/src_amplitude.yml`. The `freshness` top-level property should be moved
into the `config` of `amplitude`.
```

**IMPORTANT:** Users running dbt Core < 1.9.6 will not be able to utilize freshness tests in this release or any subsequent releases, as older versions of dbt will not recognize freshness as a source `config` and therefore not run the tests.

If you are using dbt Core < 1.9.6 and want to continue running Amplitude freshness tests, please elect **one** of the following options:
  1. (Recommended) Upgrade to dbt Core >= 1.9.6
  2. Do not upgrade your installed version of the `amplitude` package. Pin your dependency on v0.6.0 in your `packages.yml` file.
  3. Utilize a dbt [override](https://docs.getdbt.com/reference/resource-properties/overrides) to overwrite the package's `amplitude` source and apply freshness via the previous release top-level property route. This will require you to copy and paste the entirety of the previous release `src_amplitude.yml` file and add an `overrides: amplitude_source` property.

## Under the Hood
- Updates to ensure integration tests use latest version of dbt.

# dbt_amplitude v0.6.0
This release includes the following updates:

## Breaking Change
> A `--full-refresh` is required when upgrading to ensure all changes are properly applied.
- Updated `stg_amplitude__event` in the source package to filter events with `event_time` up to and including the current date, preventing data quality issues in this package's incremental models. Future events are treated as erroneous. ([#14](https://github.com/fivetran/dbt_amplitude_source/pull/14))
- As a result, the following models will no longer reference events past the current date: ([#23](https://github.com/fivetran/dbt_amplitude/pull/23))
  - `amplitude__daily_performance`
  - `amplitude__event_enhanced`
  - `amplitude__sessions`
  - `amplitude__user_enhanced`

## Features  
- Extended the lookback window in incremental models from 3 to 7 days to better capture late-arriving event records. ([#23](https://github.com/fivetran/dbt_amplitude/pull/23))

## Documentation
- Added a [DECISIONLOG](https://github.com/fivetran/dbt_amplitude/blob/main/DECISIONLOG.md#filtering-out-future-events) entry regarding the new date filter. ([#23](https://github.com/fivetran/dbt_amplitude/pull/23))
- Added Quickstart model counts to README. ([#22](https://github.com/fivetran/dbt_amplitude/pull/22))
- Corrected references to connectors and connections in the README. ([#22](https://github.com/fivetran/dbt_amplitude/pull/22))

# dbt_amplitude v0.6.0-a1
This pre-release includes the following updates:

## Features  
- Extended the lookback window in incremental models from 3 to 7 days to better capture late-arriving event records. ([#23](https://github.com/fivetran/dbt_amplitude/pull/23))

## Bug Fixes  
- Updated `stg_amplitude__event` in the source package to filter events with `event_time` up to and including the current date, preventing data quality issues in this package's incremental models. Future events are treated as erroneous. ([#14](https://github.com/fivetran/dbt_amplitude_source/pull/14))

## Documentation
- Added Quickstart model counts to README. ([#22](https://github.com/fivetran/dbt_amplitude/pull/22))
- Corrected references to connectors and connections in the README. ([#22](https://github.com/fivetran/dbt_amplitude/pull/22))

# dbt_amplitude v0.5.0
[PR #19](https://github.com/fivetran/dbt_amplitude/pull/19) includes the following updates:

## Breaking Changes
Users should perform a `--full-refresh` when upgrading to ensure all changes are applied correctly. This includes updates to unique key generation, materialization, and incremental strategies, which may affect existing records.

- Revised `unique_key` generation for `amplitude__event_enhanced` using `unique_event_id` and `unique_event_type_id` to prevent duplicate records.
    - The unique key was previously generated from `unique_event_id` and `event_day`, which caused duplicate keys for some users and prevented incremental runs.
- Made the `int_amplitude__date_spine` materialization ephemeral to reduce the number of tables and simplify incremental model dependencies.
- Updated incremental loading strategies:
  - **BigQuery** and **Databricks All-Purpose Clusters**: `insert_overwrite` for compute efficiency
    - For **Databricks SQL Warehouses**, incremental materialization will not be used due to the incompatibility of the `insert_overwrite` strategy.
  - **Snowflake**, **Redshift**, and **Postgres**: `delete+insert`

## Features
- Added a default 3-day lookback period for incremental models to handle late-arriving records. Customize the lookback duration by setting the `lookback_window` variable in `dbt_project.yml`. For more information, refer to the [Lookback Window section of the README](https://github.com/fivetran/dbt_amplitude/blob/main/README.md#lookback-window).
- Added the `amplitude_lookback` macro to simplify lookback calculations across models.
- Changed the data type of `session_started_at` and `session_ended_at` in the `amplitude__sessions` model from `timestamp` to `date` to support incremental calculations.

## Documentation updates
- Updated outdated or missing field definitions in dbt documentation.

## Under the hood
- Adjusted the `event_time` field in the `event_data` seed file to ensure records are not automatically excluded during test runs.
- Added consistency tests for end models.
- Added a new macro `is_incremental_compatible()` to identify if the Databricks SQL Warehouse runtime is being used. This macro returns `false` if the runtime is SQL Warehouse, and `true` for any other Databricks runtime or supported destination.
- Added testing for Databricks SQL Warehouses.

# dbt_amplitude v0.4.0

## Breaking Changes
- This release removes the pre-defined dbt-metric configurations within the package. These metrics relied on an old version of dbt-metrics which has since been sunset. ([PR #15](https://github.com/fivetran/dbt_amplitude/pull/15))
    - If you found these metrics to be useful and would still like to leverage them within the package, we encourage you to open a PR on this repository to convert the pre-defined metrics so they may support the new dbt Labs Metric Flow configs and requirements. 

## Under the Hood:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([PR #11](https://github.com/fivetran/dbt_amplitude/pull/11))
- Updated the pull request [templates](/.github). ([PR #11](https://github.com/fivetran/dbt_amplitude/pull/11))

# dbt_amplitude v0.3.0
## 🚨 Breaking Changes 🚨:
[PR #9](https://github.com/fivetran/dbt_amplitude/pull/9) includes the following changes:
- Rename `date_range_start` and `date_range_end` variables to `amplitude__date_range_start` and `amplitude__date_range_end` and make them global variables.
- The date range filter using `amplitude__date_range_start` and `amplitude__date_range_end` variables have been moved further upstream to `stg_amplitude__event`. 
- Removal of the configuration within the dbt_project.yml that erroneously materialized all models as tables. The models will now properly run incrementally following the initial run.
- Removal of the recursive subqueries within model incremental logic. These subqueries have been reformatted into their own CTE's to address warehouses errors that arise when handling a potential recursive relationship. The incremental logic have been updated in the following models:
   - `int_amplitude__date_spine`
   - `amplitude__daily_performance`
   - `amplitude__event_enhanced`
   - `amplitude__sessions`

- Change the coalesce clause used for deduplicating events to a case-when statement. This assures that for the scenario where `_insert_id` is null, that those respective records are not being considered and grouped as 1 event.
- Please note, a `dbt run --full-refresh` will be required after upgrading to this version in order to capture the updates.


## Under the Hood
- Add an additional dbt run to our integration testing so that we're not just running on fresh data, and so that the second run uses the same data and runs with the incremental strategy. 

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
