with facts as (
  select
    *
  from {{ ref('clean_fact_power_generation') }}
),

units as (
  select
    *
  from {{ ref('clean_dim_unit') }}
),

weather as (
  select
    *
  from {{ ref('clean_dim_weather') }}
),

joined as (
  select
    -- Fact data
    f.power_generation_id,
    f.power_generation_unit_id,
    f.start_datetime,
    f.start_date,
    f.duration_hours,
    f.value_mw,

    -- Unit data
    u.unit_name,
    u.unit_operator,
    u.unit_city,
    u.unit_state,
    u.energy_source,
    u.is_storage,
    u.plant_status,
    u.net_electrical_capacity_mw,

    -- Weather data
    w.weather_datetime,
    w.temperature_2m_c,
    w.wind_speed_10m_mps,
    w.wind_speed_80m_mps,
    w.shortwave_radiation_wpm2,
    w.direct_radiation_wpm2,
    w.diffuse_radiation_wpm2,
    w.precipitation_mm,
    w.cloud_cover_percent,
    w.pressure_msl_hpa,
    w.rain_mm,
    w.snowfall_cm,

    -- Derived metrics
    f.value_mw * f.duration_hours as energy_mwh,
    case
      when u.net_electrical_capacity_mw > 0
        then (f.value_mw / u.net_electrical_capacity_mw) * 100
    end as capacity_utilization_percent

  from facts as f
  left join units as u
    on f.power_generation_unit_id = u.power_generation_unit_id
  left join weather as w
    on
      u.unit_postal_code = w.postal_code
      and f.start_datetime = w.weather_datetime
)

select
  power_generation_unit_id,
  start_date,

  -- Unit data
  unit_name,
  unit_operator,
  unit_city,
  unit_state,
  energy_source,
  is_storage,
  plant_status,
  net_electrical_capacity_mw,

  coalesce(energy_source in ('Water', 'Biomass', 'Waste', 'Battery Storage', 'Pumped Storage'), false) as is_renewable,

  -- Weather data
  max(temperature_2m_c) as max_temperature_2m_c,
  max(wind_speed_10m_mps) as max_wind_speed_10m_mps,
  max(wind_speed_80m_mps) as max_wind_speed_80m_mps,
  max(shortwave_radiation_wpm2) as max_shortwave_radiation_wpm2,
  max(direct_radiation_wpm2) as max_direct_radiation_wpm2,
  max(diffuse_radiation_wpm2) as max_diffuse_radiation_wpm2,
  max(precipitation_mm) as max_precipitation_mm,
  max(cloud_cover_percent) as max_cloud_cover_percent,
  max(pressure_msl_hpa) as max_pressure_msl_hpa,
  max(rain_mm) as max_rain_mm,
  max(snowfall_cm) as max_snowfall_cm,
  max(energy_mwh) as max_energy_mwh,
  max(value_mw) as max_value_mw,

  avg(temperature_2m_c) as avg_temperature_2m_c,
  avg(wind_speed_10m_mps) as avg_wind_speed_10m_mps,
  avg(wind_speed_80m_mps) as avg_wind_speed_80m_mps,
  avg(shortwave_radiation_wpm2) as avg_shortwave_radiation_wpm2,
  avg(direct_radiation_wpm2) as avg_direct_radiation_wpm2,
  avg(diffuse_radiation_wpm2) as avg_diffuse_radiation_wpm2,
  avg(precipitation_mm) as avg_precipitation_mm,
  avg(cloud_cover_percent) as avg_cloud_cover_percent,
  avg(pressure_msl_hpa) as avg_pressure_msl_hpa,
  avg(rain_mm) as avg_rain_mm,
  avg(snowfall_cm) as avg_snowfall_cm,
  avg(energy_mwh) as avg_energy_mwh,
  avg(value_mw) as avg_value_mw,

  min(temperature_2m_c) as min_temperature_2m_c,
  min(wind_speed_10m_mps) as min_wind_speed_10m_mps,
  min(wind_speed_80m_mps) as min_wind_speed_80m_mps,
  min(shortwave_radiation_wpm2) as min_shortwave_radiation_wpm2,
  min(direct_radiation_wpm2) as min_direct_radiation_wpm2,
  min(diffuse_radiation_wpm2) as min_diffuse_radiation_wpm2,
  min(precipitation_mm) as min_precipitation_mm,
  min(cloud_cover_percent) as min_cloud_cover_percent,
  min(pressure_msl_hpa) as min_pressure_msl_hpa,
  min(rain_mm) as min_rain_mm,
  min(snowfall_cm) as min_snowfall_cm,
  min(energy_mwh) as min_energy_mwh,
  min(value_mw) as min_value_mw

from joined
-- Aggregate data on a daily basis per power generation unit
-- Add a new column: is_renewable for energy_source ('Water', 'Biomass', 'Waste', 'Battery Storage', 'Pumped Storage')
group by
  power_generation_unit_id,
  start_date,

  -- Unit data
  unit_name,
  unit_operator,
  unit_city,
  unit_state,
  energy_source,
  is_storage,
  plant_status,
  net_electrical_capacity_mw,
  is_renewable
