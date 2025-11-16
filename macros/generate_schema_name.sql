{% macro generate_schema_name(custom_schema_name, node) %}
  {% set re = modules.re %}
  {% set default_schema = target.schema %}
  {% set target_name = target.name %}
  {% set pr_number = ('pr' ~ env_var('DBT_CLOUD_PR_ID', '')) if env_var('DBT_CLOUD_PR_ID', '') else env_var('DBT_PR_NUMBER', 'none') %}

  {# PROD #}
  {% if target_name == 'prod' %}
      {{ custom_schema_name }}

  {# CI / INTEGRATION — let dbt Cloud create schema automatically #}
  {% elif target_name == 'int' %}
      {{ target.schema }}

  {# DEV ENVIRONMENTS #}
  {% elif target_name in ['dev', 'default'] %}
      {% set branch = env_var('DBT_CLOUD_GIT_BRANCH', env_var('DBT_CURRENT_BRANCH_NAME', '')) %}

      {% if branch %}
          {% set branch_clean = re.sub('[^\w]', '_', branch) | lower %}
          {% set suffix = branch_clean | replace("-", "_") | replace("/", "_") | lower | trim %}
      {% else %}
          {% set suffix = default_schema %}
      {% endif %}

      {{ suffix }}_{{ custom_schema_name }}

  {# FALLBACK #}
  {% else %}
      {{ custom_schema_name or target.schema }}

  {% endif %}
{% endmacro %}