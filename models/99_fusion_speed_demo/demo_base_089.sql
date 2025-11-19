-- Fusion Speed Demo: Base Model 089
select
  generation_date,
  power_generation_unit_id,
  unit_name,
  unit_state,
  energy_source,
  is_renewable,
  total_energy_mwh,
  avg_power_mw,
  avg_capacity_utilization_percent,
  avg_temperature_2m_c,
  avg_wind_speed_10m_mps
from {{ ref('mart_power_generation_daily') }}
where generation_date >= '2024-01-01'
  and total_energy_mwh > 89
