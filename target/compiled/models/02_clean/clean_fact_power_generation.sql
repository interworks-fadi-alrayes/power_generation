select
    POWERGENERATIONID as power_generation_id,
    STARTDATE as start_date,
    ENDDATE as end_date,
    POWER_GENERATIONUNITID as power_generation_unit_id,
    VALUEMW as value_mw
from SNOWFLAKE_LEARNING_DB.raw_power_generation.fact_power_generation_final