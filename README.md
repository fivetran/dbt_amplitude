<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_amplitude/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_core™-version_>=1.0.0_<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Amplitude Modeling dbt Package ([Docs](https://fivetran.github.io/dbt_amplitude/))

# 📣 What does this dbt package do?
- Produces modeled tables that leverage Amplitude data from [Fivetran's connector](https://fivetran.com/docs/applications/amplitude) in the format described by [this ERD](https://fivetran.com/docs/applications/amplitude#schema) and builds off the output of our [Amplitude source package](https://github.com/fivetran/dbt_amplitude_source).

- This package enables users to:
  - Leverage event data that is enhanced with additional event type and pivoted custom property fields for later downstream use
  - View aggregated metrics for each unique session
  - View aggregated metrics for each unique user
  - View daily performance metrics for each event type
  - Use the enhanced event data to leverage dbt metrics to generate additional analytics
  - Incorporate the [dbt product analytics](https://github.com/mjirv/dbt_product_analytics) package to further enhance Amplitude data, such as for funnel and retention analysis

This package also generates a comprehensive data dictionary of your source and modeled Amplitude data via the [dbt docs site](https://fivetran.github.io/dbt_amplitude/)
You can also refer to the table below for a detailed view of all models materialized by default within this package.

|**model**|**description**
-----|-----
| [amplitude__event_enhanced](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__event_enhanced)     | Each record represents event data, enhanced with event type data and unnested event, group, and user properties. 
| [amplitude__session_enhanced](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__session_enhanced)         | Each record represents a distinct session with aggregated metrics for that session.
| [amplitude__user_enhanced](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__user_enhanced)               | Each record represents a distinct user with aggregated metrics for that user.
| [amplitude__daily_performance](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__daily_performance)               | Each record represents performance metrics for each distinct day and event type.

# 🎯 How do I use the dbt package?
## Step 1: Pre-Requisites
You will need to ensure you have the following before leveraging the dbt package.
- **Connector**: Have the Fivetran Amplitude connector syncing data into your warehouse. 
- **Database support**: This package has been tested on **BigQuery**, **Snowflake**, **Redshift**, **Databricks**, and **Postgres**. Ensure you are using one of these supported databases.
  - If you are using Databricks you'll need to add the below to your `dbt_project.yml`. 

```yml
# dbt_project.yml

dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```
- **dbt Version**: This dbt package requires you have a functional dbt project that utilizes a dbt version within the respective range `>=1.0.0, <2.0.0`.
## Step 2: Installing the Package
Include the following amplitude package version in your `packages.yml`
> Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yaml
packages:
  - package: fivetran/amplitude
    version: [">=0.1.0", "<0.2.0"]
```
## Step 3: Configure Your Variables
### Database and Schema Variables
By default, this package will run using your target database and the `amplitude` schema. If this is not where your Amplitude data is, add the following configuration to your root `dbt_project.yml` file:

```yml
# dbt_project.yml

...
config-version: 2

vars:
    amplitude_database: your_database_name    
    amplitude_schema: your_schema_name
```

## (Optional) Step 4: Additional Configurations
<details><summary>Expand for configurations</summary>

### Change the Source Table References
Source tables are referenced using default names. If an individual source table has a different name than expected, provide the name of the table as it appears in your warehouse to the respective variable: 
> IMPORTANT: See the package's source [`dbt_project.yml`](https://github.com/fivetran/dbt_amplitude_source/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
# dbt_project.yml
...
config-version: 2
vars:
    <package_name>__<default_source_table_name>_identifier: your_table_name
```

### Change the Build Schema
By default, this package builds the GitHub staging models within a schema titled (<target_schema> + `_stg_amplitude`) in your target database. If this is not where you would like your GitHub staging data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
# dbt_project.yml
models:
    amplitude_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```
### Change the Date Range
The default date range starts at '2020-01-01' and ends one day past the current day. To customize the date range, add the following configurations to your root `dbt_project.yml` file:
```yml
# dbt_project.yml
...
vars:
    date_range_start: your_starting_date
    date_range_end: your_ending_date
```
### Pivoting Out Nested Fields Containing Custom Properties
The Amplitude schema allows for custom properties to be passed as nested fields (for example: `user_properties: {"Cohort":"Test A"}`). To pivot out the properties, add the following configurations to your root `dbt_project.yml` file:
```yml
# dbt_project.yml
...
vars:
    event_properties_to_pivot: ['event_property_1','event_property_2']
    group_properties_to_pivot: ['group_property_1','group_property_2']
    user_properties_to_pivot: ['user_property_1','user_property_2']
```
</details>

## (Optional) Step 5: Leverage dbt Metrics for Further Analysis
<details><summary>Expand for configurations</summary>

In addition to existing final models, our Amplitude package defines common [Metrics](https://docs.getdbt.com/docs/building-a-dbt-project/metrics) including:
- total_events
- average_session_length
- total_sessions
- total_users
- average_time_in_between_sessions

You can find the supported dimensions and full definitions of these metrics [here](https://github.com/fivetran/dbt_ad_reporting/blob/main/models/ad_reporting_metrics.yml).

To use dbt Metrics, add the [dbt metrics package](https://github.com/dbt-labs/dbt_metrics) to your project's `packages.yml` file:
```yml
packages:
  - package: dbt-labs/metrics
    version: [">=0.3.0", "<0.4.0"]
```
> **Note**: The Metrics package has stricter dbt version requirements. As of today, the latest version of Metrics (v0.3.5) requires dbt `[">=1.2.0-a1", "<2.0.0"]`.

To utilize the Ad Reporting's pre-defined metrics in your code, refer to the [dbt metrics package](https://github.com/dbt-labs/dbt_metrics) usage instructions and the example below:
```sql
select * 
from {{ metrics.calculate(
        metric('total_events'),
        grain='month',
        dimensions=['region'],
        secondary_calculations=[
            metrics.period_over_period(comparison_strategy='ratio', interval=1, alias='ratio_last_mth'),
            metrics.period_over_period(comparison_strategy='ratio', interval=12, alias='ratio_last_yr'),
            metrics.period_to_date(aggregate='sum', period='year', alias='ytd')
        ]
) }}
```
</details>
<br>

## (Optional) Step 6: Using the dbt Product Analytics package in conjunction
<details><summary>Expand for configurations</summary>

 <!-- complete -->

</details>
<br>

## (Optional) Step 7: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through the [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt) product. Refer to the linked docs for more information on how to setup your project for orchestration through Fivetran. 
</details>

# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
```yml
packages:
    - package: fivetran/amplitude_source
      version: [">=0.1.0", "<0.2.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.3.0", "<0.4.0"]

    - package: dbt-labs/dbt_utils
      version: [">=0.8.0", "<0.9.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package **only** maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/amplitude/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_amplitude/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.
## Contributions
These dbt packages are developed by a small team of analytics engineers at Fivetran. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package!

# 🏪 Are there any resources available?
- If you encounter any questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_amplitude/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran, or would like to request a future dbt package to be developed, then feel free to fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to just say hi? Book a time during our office hours [here](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or send us an email at solutions@fivetran.com.
