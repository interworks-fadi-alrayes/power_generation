{% macro delete_dev_schemas_by_branch(branch_name) -%}
  {#-
    Deletes all development schemas matching a branch name prefix.

    Used in CI/CD workflows to clean up schemas after PR merge or branch deletion.
    This prevents schema proliferation in the development database and reduces
    storage costs.

    The macro:
    1. Sanitizes the branch name to match dbt's schema naming convention
    2. Searches for all schemas with the matching prefix
    3. Drops each schema with CASCADE to remove all objects

    Example: For branch 'feature-branch', deletes schemas like:
    - feature_branch_O0_UTILITY
    - feature_branch_O2_CLEAN
    - feature_branch_O3_MART

    Usage: dbt run-operation delete_dev_schemas_by_branch --args '{branch_name: feature-branch}'
  -#}

  {%- set database = 'power_generation_dev' -%}
  {%- set re = modules.re -%}
  {%- set schema_prefix = re.sub('[^\w]', '_', branch_name) | lower | trim -%}

  {{ log("Searching for schemas in " ~ database ~ " with prefix: " ~ schema_prefix, info=True) }}

  {#- Query to find all schemas matching the branch prefix -#}
  {%- set sql_find_schemas -%}
    SELECT schema_name
    FROM {{ database }}.information_schema.schemata
    WHERE lower(schema_name) LIKE '{{ schema_prefix }}_%'
      AND schema_name NOT IN ('INFORMATION_SCHEMA', 'PUBLIC')
  {%- endset -%}

  {%- set results = run_query(sql_find_schemas) -%}

  {#- Drop each schema found -#}
  {%- if results is not none and results | length > 0 -%}
    {%- set schemas = results.columns[0].values() -%}
    {{ log("Found " ~ schemas | length ~ " schema(s) to drop", info=True) }}

    {%- for schema in schemas -%}
      {{ log("Dropping schema: " ~ database ~ "." ~ schema, info=True) }}

      {%- set sql_drop -%}
        DROP SCHEMA IF EXISTS {{ database }}.{{ schema }} CASCADE
      {%- endset -%}

      {%- do run_query(sql_drop) -%}
      {{ log("Successfully dropped: " ~ database ~ "." ~ schema, info=True) }}
    {%- endfor -%}

  {#- No schemas found matching the prefix -#}
  {%- else -%}
    {{ log("No schemas found matching prefix: " ~ schema_prefix, info=True) }}
  {%- endif -%}

  {{ log("Schema cleanup completed", info=True) }}

{%- endmacro %}
