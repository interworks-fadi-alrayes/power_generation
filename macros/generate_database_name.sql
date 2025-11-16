{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {%- set default_database = target.database -%}

    {% if target.name == 'prod' %}
        {{ 'power_generation_prod' }}
    {% elif target.name == 'ci' %}
        {{ 'power_generation_ci' }}
    {% else %}
        {{ 'power_generation_dev' }}
    {% endif %}

{%- endmacro %}


