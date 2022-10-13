# dbt_amplitude v0.1.0
🎉 Initial Release 🎉


- Ensures that the incremental strategy used by Postgres and Redshift adapters in the `shopify_holistic_reporting__orders_attribution` model is `delete+insert` ([#9](https://github.com/fivetran/dbt_shopify_holistic_reporting/pull/9)). Newer versions of dbt introduced an error message if the provided incremental strategy is not `append` or `delete+insert` for these adapters.