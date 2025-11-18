select
  powergenerationid as power_generation_id,
  power_generationunitid as power_generation_unit_id,
  valuemw as value_mw,

  -- Parse timestamps
  to_timestamp(startdate, 'DD.MM.YYYY HH24:MI') as start_datetime,
  to_date(to_timestamp(startdate, 'DD.MM.YYYY HH24:MI')) as start_date,

  -- Calculate duration in hours
  datediff(
    hour,
    to_timestamp(startdate, 'DD.MM.YYYY HH24:MI'),
    to_timestamp(enddate, 'DD.MM.YYYY HH24:MI')
  ) as duration_hours

from {{ source('smard', 'fact_power_generation') }}
