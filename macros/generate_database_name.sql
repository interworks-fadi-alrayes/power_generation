{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {%- set default_database = target.database -%}

    {% if target.name == 'prod' %}
        {{ 'power_generation_prod' }}

    {% elif target.name == 'int' %}
        {{ 'power_generation_int' }}
        
    {% else %}
        {{ 'power_generation_dev' }}
    {% endif %}

{%- endmacro %}


