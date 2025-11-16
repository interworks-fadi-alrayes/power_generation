{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {%- set default_database = target.database -%}
    {%- set base_database = custom_database_name | trim | lower -%}
    {%- set base_project = project_name -%}

    {# Use dev suffix for non-prod environments #}
    {% if target.name == 'prod' %}
        {%- set generated_database = 'power_generation_prod' -%}
    {% elif target.name == 'ci' %}
        {%- set generated_database = 'power_generation_ci' -%}
    {%- else -%}
        {%- set generated_database = 'power_generation_dev' -%}
    {%- endif -%}

    {{ generated_database }}

 
{%- endmacro %}


