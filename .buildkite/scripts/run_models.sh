#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools
pip install -r integration_tests/requirements.txt
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
if [ "$db" = "databricks-sql" ]; then
dbt seed --vars '{amplitude_schema: amplitude_sqlw_tests}' --target "$db" --full-refresh
dbt source freshness --target "$db" || echo "...Only verifying freshness runs…"
dbt compile --vars '{amplitude_schema: amplitude_sqlw_tests}' --target "$db"
dbt run --vars '{amplitude_schema: amplitude_sqlw_tests}' --target "$db" --full-refresh
dbt test --vars '{amplitude_schema: amplitude_sqlw_tests}' --target "$db"
dbt run --vars '{amplitude_schema: amplitude_sqlw_tests}' --target "$db"
dbt test --vars '{amplitude_schema: amplitude_sqlw_tests}' --target "$db"
else
dbt seed --target "$db" --full-refresh
dbt source freshness --target "$db" || echo "...Only verifying freshness runs…"
dbt compile --target "$db"
dbt run --target "$db" --full-refresh
dbt test --target "$db"
dbt run --target "$db"
dbt test --target "$db"
fi
dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"
