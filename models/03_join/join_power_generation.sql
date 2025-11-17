with fact as (
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

fact_parsed as (
  select
    power_generation_id,
    power_generation_unit_id,
    value_mw,

    -- Parse timestamps
    to_timestamp(start_date, 'DD.MM.YYYY HH24:MI') as start_datetime,
    to_timestamp(end_date, 'DD.MM.YYYY HH24:MI') as end_datetime,
    to_date(to_timestamp(start_date, 'DD.MM.YYYY HH24:MI')) as start_date_only,

    -- Calculate duration in hours
    datediff(
      hour,
      to_timestamp(start_date, 'DD.MM.YYYY HH24:MI'),
      to_timestamp(end_date, 'DD.MM.YYYY HH24:MI')
    ) as duration_hours

  from fact
),

weather_parsed as (
  select
    postal_code,
    to_timestamp(timestamp_cet) as weather_datetime,

    -- Weather measurements
    temperature_2m_c,
    wind_speed_10m_mps,
    wind_speed_80m_mps,
    shortwave_radiation_wpm2,
    direct_radiation_wpm2,
    diffuse_radiation_wpm2,
    precipitation_mm,
    cloud_cover_percent,
    pressure_msl_hpa,
    rain_mm,
    snowfall_cm

  from weather
)

select
  -- Fact identifiers
  fp.power_generation_id,
  fp.power_generation_unit_id,

  -- Unit information
  u.unit_name,
  u.operator,
  u.unit_city,
  u.unit_state,
  u.energy_source,
  u.is_storage,
  u.plant_status,
  u.gross_capacity_mw,
  u.net_electrical_capacity_mw,

  -- Power generation temporal data
  fp.start_datetime,
  fp.end_datetime,
  fp.start_date_only,
  fp.duration_hours,

  -- Power generation measurements
  fp.value_mw,

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

  -- Calculated metrics
  fp.value_mw * fp.duration_hours as energy_mwh,
  case
    when u.net_electrical_capacity_mw > 0
      then (fp.value_mw / u.net_electrical_capacity_mw) * 100
  end as capacity_utilization_percent

from fact_parsed as fp
left join units as u
  on fp.power_generation_unit_id = u.power_generation_unit_id
left join weather_parsed as w
  on
    u.unit_postal_code = w.postal_code
    and fp.start_datetime = w.weather_datetime
