{% macro generate_schema_name(custom_schema_name, node) %}
  {%- set re = modules.re -%}
  {%- set default_schema = target.schema -%}
  {% set target_name = target.name %}
    {% set pr_number = ('pr' ~ env_var('DBT_CLOUD_PR_ID', '')) if env_var('DBT_CLOUD_PR_ID', '') else env_var('DBT_PR_NUMBER', 'none') %}


  {% if target_name == 'ci' %}
    {{ custom_schema_name }}_{{ pr_number | lower | trim }}

  {% elif target_name == 'prod' %}
    {# Prod: Just use custom schema name as-is #}
    {{ custom_schema_name }}

  {% elif target_name in ['dev', 'default'] %}
    {# Dev: Custom schema + branch name suffix #}
    {% set branch = env_var('DBT_CLOUD_GIT_BRANCH', env_var('DBT_CURRENT_BRANCH_NAME', '')) %}

    {% if branch %}
      {%- set branch_clean = re.sub('[^\w]', '_', branch) | lower -%}
      {%- set suffix = branch_clean | replace("-", "_") | replace("/", "_") | lower | trim -%}
    {% else %}
      {# If no branch name, use default schema as suffix (e.g., dbt_fr) #}
      {%- set suffix = default_schema -%}
    {% endif %}

    {{ custom_schema_name }}_{{ suffix }}

  {% else %}
    {# Fallback for other targets #}
    {{ custom_schema_name }}

  {% endif %}
{% endmacro %}
