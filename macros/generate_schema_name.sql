{% macro generate_schema_name(custom_schema_name, node) -%}
  {#-
    Generates schema names based on environment and branch context.

    Schema naming strategy:
    - Production: Uses the custom schema name directly (e.g., O2_CLEAN, O3_MART)
    - Integration/CI: Uses dbt Cloud's auto-generated schema (includes PR number)
    - Development: Prefixes schema with sanitized branch name (e.g., fix_linting_errors_O2_CLEAN)

    This ensures schema isolation across:
    - Environments (prod/int/dev)
    - Developers (via branch names)
    - Pull requests (via PR numbers in CI)

    Usage: Automatically invoked by dbt during model compilation
  -#}

  {%- set re = modules.re -%}
  {%- set default_schema = target.schema -%}
  {%- set target_name = target.name -%}
  {%- set pr_number = ('pr' ~ env_var('DBT_CLOUD_PR_ID', '')) if env_var('DBT_CLOUD_PR_ID', '') else env_var('DBT_PR_NUMBER', 'none') -%}

  {#- Production environment: use custom schema name only -#}
  {%- if target_name == 'prod' -%}
    {{ custom_schema_name }}

  {#- Integration/CI environment: let dbt Cloud create schema automatically -#}
  {%- elif target_name == 'int' -%}
    {{ target.schema }}

  {#- Development environments: prefix with sanitized branch name -#}
  {%- elif target_name in ['dev', 'default'] -%}
    {%- set branch = env_var('DBT_CLOUD_GIT_BRANCH', env_var('DBT_CURRENT_BRANCH_NAME', '')) -%}

    {%- if branch -%}
      {%- set branch_clean = re.sub('[^\w]', '_', branch) | lower -%}
      {%- set suffix = branch_clean | replace("-", "_") | replace("/", "_") | lower | trim -%}
    {%- else -%}
      {%- set suffix = default_schema -%}
    {%- endif -%}

    {{ suffix }}_{{ custom_schema_name }}

  {#- Fallback for unknown environments -#}
  {%- else -%}
    {{ custom_schema_name or target.schema }}

  {%- endif -%}

{%- endmacro %}
