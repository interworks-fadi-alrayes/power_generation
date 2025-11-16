select
    POWERGENERATIONID as POWER_GENERATION_ID,
    STARTDATE as START_DATE,
    ENDDATE as END_DATE,
    POWER_GENERATIONUNITID as POWER_GENERATION_UNIT_ID,
    VALUEMW as VALUE_MW
from {{ source('raw_power_generation', 'fact_power_generation') }}
