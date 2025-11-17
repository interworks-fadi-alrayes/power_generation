select distinct
  powergenerationid as power_generation_id,
  startdate as start_date,
  enddate as end_date,
  power_generationunitid as power_generation_unit_id,
  valuemw as value_mw
from {{ source('raw_power_generation', 'fact_power_generation') }}
