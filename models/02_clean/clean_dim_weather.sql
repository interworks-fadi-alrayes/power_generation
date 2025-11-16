select
  time,
  temperature_2m_c,
  wind_speed_10m_m_s,
  wind_speed_80m_m_s,
  shortwave_radiation_w_m2,
  direct_radiation_w_m2,
  diffuse_radiation_w_m2,
  precipitation_mm,
  cloudcover as cloud_cover,
  pressure_msl_hpa,
  rain_mm,
  snowfall_cm,
  postal_code,
  country_english,
  latitude,
  longitude
from {{ source('raw_power_generation', 'dim_weather') }}
