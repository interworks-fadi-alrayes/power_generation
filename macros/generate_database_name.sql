{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {%- set default_database = target.database -%}

    {# Use custom database if provided, otherwise use target.database #}
    {% if custom_database_name %}
        {{ custom_database_name }}
    {% elif target.name == 'prod' %}
        {{ 'power_generation_prod' }}
    {% elif target.name == 'ci' %}
        {{ 'power_generation_ci' }}
    {% else %}
        {# For dev, use the existing database from target #}
        {{ default_database }}
    {% endif %}

{%- endmacro %}


