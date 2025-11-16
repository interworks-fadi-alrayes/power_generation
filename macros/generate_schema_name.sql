{% macro generate_schema_name(custom_schema_name, node) %}
  {%- set re = modules.re -%}
  {% set target_name = target.name %}
  {% set branch = env_var('DBT_CLOUD_GIT_BRANCH', env_var('DBT_CURRENT_BRANCH_NAME', 'none')) %}

  {%- set branch_clean = re.sub('[^\w]', '_', branch) | lower -%}
  {% set pr_number = ('pr' ~ env_var('DBT_CLOUD_PR_ID', '')) if env_var('DBT_CLOUD_PR_ID', '') else env_var('DBT_PR_NUMBER', 'none') %}

  {% if target_name == 'prod' %}
    {{ custom_schema_name }}

  {% elif target_name == 'dev' %}
    {{ custom_schema_name }}_{{ branch_clean | replace("-", "_") | replace("/", "_") | lower | trim }}

  --{% elif target_name == 'ci' %}
  --  {{ custom_schema_name }}_{{ pr_number | lower | trim }}

  {% else %}
    {{ custom_schema_name }}

  {% endif %}
{% endmacro %}
