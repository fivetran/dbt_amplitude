<!--section="amplitude_transformation_model"-->
# Amplitude dbt Package

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_amplitude/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0,_<3.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/data-models/quickstart-management#quickstartmanagement">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

This dbt package transforms data from Fivetran's Amplitude connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 8
- Connector documentation
  - [Amplitude connector documentation](https://fivetran.com/docs/connectors/applications/amplitude)
  - [Amplitude ERD](https://fivetran.com/docs/connectors/applications/amplitude#schemainformation)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_amplitude)
  - [dbt Docs](https://fivetran.github.io/dbt_amplitude/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_amplitude/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_amplitude/blob/main/CHANGELOG.md)

## What does this dbt package do?
This package enables you to leverage enhanced event data, view aggregated session and user metrics, and analyze daily performance metrics. It creates enriched models with metrics focused on event analysis, user behavior, and session tracking.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_amplitude
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| [amplitude__event_enhanced](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__event_enhanced) | Tracks individual user events with enriched event type data, device information, location details, and unnested custom properties to analyze user behavior and product interactions at the event level. <br></br>**Example Analytics Questions:**<ul><li>Which event types are most frequently triggered by users across different platforms or devices?</li><li>How do event patterns vary by user location (city, country) or device type (iOS vs Android)?</li><li>What custom event properties correlate with higher user engagement or conversion?</li></ul>|
| [amplitude__sessions](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__sessions) | Aggregates user activity into distinct sessions with metrics on session duration, event counts, and user actions to understand engagement patterns and session quality. <br></br>**Example Analytics Questions:**<ul><li>What is the average session duration and event count per session by user segment?</li><li>Which sessions have the highest engagement levels based on event frequency?</li><li>How do session metrics vary between new and returning users?</li></ul>|
| [amplitude__user_enhanced](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__user_enhanced) | Provides a comprehensive view of each user with lifetime metrics including total events, sessions, and engagement patterns to understand user behavior and value. <br></br>**Example Analytics Questions:**<ul><li>Which users are most engaged based on total events and session counts?</li><li>What is the distribution of user engagement metrics across different user segments?</li><li>How do user engagement metrics change over their lifetime?</li></ul>|
| [amplitude__daily_performance](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__daily_performance) | Summarizes daily event activity by event type with user and session metrics to track product usage trends and identify patterns over time. <br></br>**Example Analytics Questions:**<ul><li>How are daily active users and event volumes trending by event type?</li><li>Which event types show the strongest day-over-day or week-over-week growth?</li><li>What days of the week have the highest event activity for key user actions?</li></ul>|

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.

---

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Amplitude connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/data-models/quickstart-management).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_amplitude/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

<!--section-end-->

### Install the package
Include the following Amplitude package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/amplitude
    version: 1.3.1-a1
```

> All required sources and staging models are now bundled into this transformation package. Do not include `fivetran/amplitude_source` in your `packages.yml` since this package has been deprecated.

#### Databricks dispatch configuration
If you are using a Databricks destination with this package, you must add the following (or a variation of the following) dispatch configuration within your `dbt_project.yml` file. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Database Incremental Strategies
This package's incremental models are configured to leverage the different incremental strategies for each supported warehouse.

For **BigQuery** and **Databricks All Purpose Cluster runtime** destinations, we have chosen insert_overwrite as the default strategy, which benefits from the partitioning capability. 
> For **Databricks SQL Warehouse** destinations, models are materialized as tables without support for incremental runs.

For **Snowflake**, **Redshift**, and **Postgres** databases, we have chosen delete+insert as the default strategy.  

> Regardless of strategy, we recommend that users periodically run a --full-refresh to ensure a high level of data quality.

### Define database and schema variables

#### Option A: Single connection
By default, this package runs using your [destination](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile) and the `amplitude` schema. If this is not where your Amplitude data is (for example, if your Amplitude schema is named `amplitude_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  amplitude:
    amplitude_database: your_database_name
    amplitude_schema: your_schema_name
```

#### Option B: Union multiple connections
If you have multiple Amplitude connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. For each source table, the package will union all of the data together and pass the unioned table into the transformations. The `source_relation` column in each model indicates the origin of each record.

To use this functionality, you will need to set the `amplitude_sources` variable in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
  amplitude:
    amplitude_sources:
      - database: connection_1_destination_name # Required
        schema: connection_1_schema_name # Required
        name: connection_1_source_name # Required only if following the step in the following subsection

      - database: connection_2_destination_name
        schema: connection_2_schema_name
        name: connection_2_source_name
```

##### Recommended: Incorporate unioned sources into DAG
> *If you are running the package through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore), the below step is necessary in order to synchronize model runs with your Amplitude connections. Alternatively, you may choose to run the package through Fivetran [Quickstart](https://fivetran.com/docs/transformations/quickstart), which would create separate sets of models for each Amplitude source rather than one set of unioned models.*

By default, this package defines one single-connection source, called `amplitude`, which will be disabled if you are unioning multiple connections. This means that your DAG will not include your Amplitude sources, though the package will run successfully.

To properly incorporate all of your Amplitude connections into your project's DAG:
1. Define each of your sources in a `.yml` file in your project. Utilize the following template for the `source`-level configurations, and, **most importantly**, copy and paste the table and column-level definitions from the package's `src_amplitude.yml` [file](https://github.com/fivetran/dbt_amplitude/blob/main/models/staging/src_amplitude.yml).

```yml
# a .yml file in your root project

version: 2

sources:
  - name: <name> # ex: Should match name in amplitude_sources
    schema: <schema_name>
    database: <database_name>
    loader: fivetran
    config:
      loaded_at_field: _fivetran_synced
      freshness: # feel free to adjust to your liking
        warn_after: {count: 72, period: hour}
        error_after: {count: 168, period: hour}

    tables: # copy and paste from amplitude/models/staging/src_amplitude.yml - see https://support.atlassian.com/bitbucket-cloud/docs/yaml-anchors/ for how to use anchors to only do so once
```

> **Note**: If there are source tables you do not have (see [Configure event date range](https://github.com/fivetran/dbt_amplitude?tab=readme-ov-file#configure-event-date-range)), you may still include them, as long as you have set the right variables to `False`.

2. Set the `has_defined_sources` variable (scoped to the `amplitude` package) to `True`, like such:
```yml
# dbt_project.yml
vars:
  amplitude:
    has_defined_sources: true
```
### Configure event date range
Because of the typical volume of event data, you may want to limit this package's models to work with a recent date range. 

The default date range starts at `'2020-01-01'` and extends up to and including the current date for the [`stg_amplitude__event`](https://github.com/fivetran/dbt_amplitude/blob/main/models/staging/stg_amplitude__event.sql) and [`date spine`](https://github.com/fivetran/dbt_amplitude/blob/main/models/intermediate/int_amplitude__date_spine.sql) models. To customize the date range, add the following configurations to your root `dbt_project.yml` file:

```yml
vars:
    amplitude__date_range_start: '2022-01-01' # your start date here
    amplitude__date_range_end: '2022-12-01' # your end date here
```
NOTE: The `amplitude__daily_performance`, `amplitude__event_enhanced`, and `amplitude__sessions` models are materialized as incremental. Updating the date range in `dbt_project.yml` will only apply to newly ingested data. If you modify the date range variables, we recommend running `dbt run --full-refresh` to ensure consistency across the adjusted date range.

### (Optional) Additional configurations
<details open><summary>Expand/collapse configurations</summary>

#### Lookback Window
Records from the source can sometimes arrive late. Since several of the models in this package are incremental, by default we look back 3 days from new records to ensure late arrivals are captured and avoiding the need for frequent full refreshes. While the frequency can be reduced, we still recommend running `dbt --full-refresh` periodically to maintain data quality of the models. 

To change the default lookback window, add the following variable to your `dbt_project.yml` file:

```yml
vars:
  amplitude:
    lookback_window: number_of_days # default is 3
```

#### Change source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See the package's source [`dbt_project.yml`](https://github.com/fivetran/dbt_amplitude/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    <package_name>__<default_source_table_name>_identifier: your_table_name
```

#### Change the Build Schema
By default, this package builds out the Amplitude staging models within a schema titled (<target_schema> + `_source_amplitude`) in your target database, and the Amplitude end models in a schema titled (<target_schema> + `amplitude`) in your target database. If this is not where you would like your Amplitude data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
# dbt_project.yml
models:
    amplitude:
      +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
      staging:
        +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
```
#### Pivot out nested fields containing custom properties
The Amplitude schema allows for custom properties to be passed as nested fields (for example, `user_properties: {"Cohort":"Test A"}`). To pivot out the properties, add the following configurations to your root `dbt_project.yml` file:

```yml
vars:
    event_properties_to_pivot: ['event_property_1','event_property_2']
    group_properties_to_pivot: ['group_property_1','group_property_2']
    user_properties_to_pivot: ['user_property_1','user_property_2']
```
</details>
<br>

### (Optional) Using this package with the dbt Product Analytics package
<details><summary>Expand for configurations</summary>

The [dbt_product_analytics](https://github.com/mjirv/dbt_product_analytics) package contains macros that allows for further exploration such as event flow, funnel, and retention analysis. To leverage this in conjunction with this package, add the following configuration to your project's `packages.yml` file:
```yml
packages:
  - package: mjirv/dbt_product_analytics
    version: [">=0.1.0"]
```

Refer to the [dbt_product_analytics](https://github.com/mjirv/dbt_product_analytics) usage instructions and the example below:
```sql
-- # product_analytics_funnel.sql
{% set events =
  dbt_product_analytics.event_stream(
    from=ref('amplitude__event_enhanced'),
    event_type_col="event_type",
    user_id_col="amplitude_user_id",
    date_col="event_day",
    start_date="your_start_date",
    end_date="your_end_date")
%}

{% set steps = ["event_type_1", "event_type_2", "event_type_3"] %}

{{ dbt_product_analytics.funnel(steps=steps, event_stream=events) }}

```

</details>
<br>

### (Optional) Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core™ setup guides](https://fivetran.com/docs/transformations/dbt/setup-guide#transformationsfordbtcoresetupguide).

</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
<!--section="amplitude_maintenance"-->
## How is this package maintained and can I contribute?

### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/amplitude/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_amplitude/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

### Opinionated Decisions
In creating this package, which is meant for a wide range of use cases, we had to take opinionated stances on a few different questions we came across during development. We've consolidated significant choices we made in the [DECISIONLOG.md](https://github.com/fivetran/dbt_amplitude/blob/main/DECISIONLOG.md), and will continue to update as the package evolves. We are always open to and encourage feedback on these choices, and the package in general.

<!--section-end-->

## Are there any resources available?
- If you encounter any questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_amplitude/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran, or would like to request a future dbt package to be developed, then feel free to fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
