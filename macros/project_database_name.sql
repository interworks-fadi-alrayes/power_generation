{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {%- set default_database = target.database -%}
    {%- set base_database = custom_database_name | trim | lower -%}
    {%- set base_project = project_name -%}

    {# Use dev suffix for non-prod environments #}
    {% if target.name == 'prod' %}
        {%- set generated_database = 'power_generation_PROD' -%}
    {%- else -%}
        {%- set generated_database = 'power_generation_DEV' -%}
    {%- endif -%}

    {{ generated_database }}

 
{%- endmacro %}


