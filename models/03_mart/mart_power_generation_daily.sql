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
  *
from joined
-- Aggregate data on a daily basis per power generation unit.
-- Add a new column: is_renewable for energy_source ('Water', 'Biomass', 'Waste', 'Battery Storage', 'Pumped Storage')
