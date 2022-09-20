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
## finish

# mention all the vars in dbt project yml

This package also generates a comprehensive data dictionary of your source and modeled Amplitude data via the [dbt docs site](https://fivetran.github.io/dbt_amplitude/)
You can also refer to the table below for a detailed view of all models materialized by default within this package.

|**model**|**description**
-----|-----
| [amplitude__event_enhanced](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__event_enhanced)     |Each record represents 
| [amplitude__session_enhanced](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__session_enhanced)         |Each record represents 
| [amplitude__user_enhanced](https://fivetran.github.io/dbt_amplitude/#!/model/model.amplitude.amplitude__user_enhanced)               |Each record represents 

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
models:
    amplitude_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```

## (Optional) Step 5: Orchestrate your models with Fivetran Transformations for dbt Core™
Fivetran offers the ability for you to orchestrate your dbt project through the [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt) product. Refer to the linked docs for more information on how to setup your project for orchestration through Fivetran. 

# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. For more information on the below packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> **If you have any of these dependent packages in your own `packages.yml` I highly recommend you remove them to ensure there are no package version conflicts.**
```yml
packages:
    - package: fivetran/amplitude_source
      version: [">=0.1.0", "<0.2.0"]
    - package: fivetran/fivetran_utils
      version: [">=0.3.0", "<0.4.0"]
    - package: dbt-labs/dbt_utils
      version: [">=0.1.0", "<0.2.0"]
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
