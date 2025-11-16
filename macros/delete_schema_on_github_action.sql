{% macro delete_dev_schemas_by_branch(branch_name) %}
  {#-
    Deletes all development schemas matching a branch name suffix.
    Used in CI/CD to clean up schemas after PR merge.

    Usage: dbt run-operation delete_dev_schemas_by_branch --args '{branch_name: feature-branch}'
  -#}

  {%- set database = 'power_generation_dev' -%}
  {%- set re = modules.re -%}
  {%- set schema_suffix = re.sub('[^\w]', '_', branch_name) | lower | trim  -%}

  {{ log("Searching for schemas in " ~ database ~ " with suffix: " ~ schema_suffix, info=True) }}

  {%- set sql_find_schemas %}
    SELECT schema_name
    FROM {{ database }}.information_schema.schemata
    WHERE lower(schema_name) LIKE '%_{{ schema_suffix }}'
      AND schema_name NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
  {%- endset %}

  {%- set results = run_query(sql_find_schemas) -%}

  {%- if results is not none and results | length > 0 %}
    {%- set schemas = results.columns[0].values() -%}
    {{ log("Found " ~ schemas | length ~ " schema(s) to drop", info=True) }}

    {%- for schema in schemas %}
      {{ log("Dropping schema: " ~ database ~ "." ~ schema, info=True) }}
      {%- set sql_drop %}
        DROP SCHEMA IF EXISTS {{ database }}.{{ schema }} CASCADE
      {%- endset %}
      {% do run_query(sql_drop) %}
      {{ log("Successfully dropped: " ~ database ~ "." ~ schema, info=True) }}
    {%- endfor %}
  {%- else %}
    {{ log("No schemas found matching suffix: " ~ schema_suffix, info=True) }}
  {%- endif %}

  {{ log("Schema cleanup completed", info=True) }}
{% endmacro %}
