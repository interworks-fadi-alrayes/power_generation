with joined as (
  select
    *
  from {{ ref('join_power_generation') }}
)

select
  -- Date dimension
  start_date as generation_date,

  -- Unit dimension
  power_generation_unit_id,
  unit_name,
  unit_operator,
  unit_city,
  unit_state,
  energy_source,
  plant_status,
  is_storage,

  -- Unit capacity (takes latest value per day)
  max(net_electrical_capacity_mw) as net_electrical_capacity_mw,

  -- Power generation aggregations
  count(*) as number_of_readings,
  sum(duration_hours) as total_duration_hours,
  sum(energy_mwh) as total_energy_mwh,

  avg(value_mw) as avg_power_mw,
  min(value_mw) as min_power_mw,
  max(value_mw) as max_power_mw,

  -- Capacity utilization
  avg(capacity_utilization_percent) as avg_capacity_utilization_percent,
  max(capacity_utilization_percent) as max_capacity_utilization_percent,

  -- Weather aggregations (daily averages)
  avg(temperature_2m_c) as avg_temperature_2m_c,
  min(temperature_2m_c) as min_temperature_2m_c,
  max(temperature_2m_c) as max_temperature_2m_c,

  avg(wind_speed_10m_mps) as avg_wind_speed_10m_mps,
  avg(wind_speed_80m_mps) as avg_wind_speed_80m_mps,

  avg(shortwave_radiation_wpm2) as avg_shortwave_radiation_wpm2,
  avg(direct_radiation_wpm2) as avg_direct_radiation_wpm2,
  avg(diffuse_radiation_wpm2) as avg_diffuse_radiation_wpm2,

  sum(precipitation_mm) as total_precipitation_mm,
  sum(rain_mm) as total_rain_mm,
  sum(snowfall_cm) as total_snowfall_cm,

  avg(cloud_cover_percent) as avg_cloud_cover_percent,
  avg(pressure_msl_hpa) as avg_pressure_msl_hpa

from joined
group by
  start_date,
  power_generation_unit_id,
  unit_name,
  unit_operator,
  unit_city,
  unit_state,
  energy_source,
  plant_status,
  is_storage
