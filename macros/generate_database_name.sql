{% macro generate_database_name(custom_database_name=none, node=none) -%}
  {#-
    Generates the target database name based on the dbt target environment.

    This macro ensures consistent database naming across environments:
    - Production: Uses 'power_generation_prod' database
    - Integration/CI: Uses 'power_generation_int' database
    - Development: Uses 'power_generation_dev' database

    The custom_database_name parameter is ignored to enforce consistent naming.

    Usage: Automatically invoked by dbt during model compilation
  -#}

  {%- set default_database = target.database -%}

  {#- Production environment -#}
  {%- if target.name == 'prod' -%}
    {{ 'power_generation_prod' }}

  {#- Integration/CI environment -#}
  {%- elif target.name == 'int' -%}
    {{ 'power_generation_int' }}

  {#- Development and default environments -#}
  {%- else -%}
    {{ 'power_generation_dev' }}
  {%- endif -%}

{%- endmacro %}
