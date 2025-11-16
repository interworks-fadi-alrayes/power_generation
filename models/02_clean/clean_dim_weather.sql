select
    TIME as time,
    TEMPERATURE_2M_C as temperature_2m_c,
    WIND_SPEED_10M_M_S as wind_speed_10m_m_s,
    WIND_SPEED_80M_M_S as wind_speed_80m_m_s,
    SHORTWAVE_RADIATION_W_M2 as shortwave_radiation_w_m2,
    DIRECT_RADIATION_W_M2 as direct_radiation_w_m2,
    DIFFUSE_RADIATION_W_M2 as diffuse_radiation_w_m2,
    PRECIPITATION_MM as precipitation_mm,
    CLOUDCOVER as cloud_cover,
    PRESSURE_MSL_HPA as pressure_msl_hpa,
    RAIN_MM as rain_mm,
    SNOWFALL_CM as snowfall_cm,
    POSTAL_CODE as postal_code,
    COUNTRY_ENGLISH as country_english,
    LATITUDE as latitude,
    LONGITUDE as longitude
from {{ source('raw_power_generation', 'dim_weather') }}
