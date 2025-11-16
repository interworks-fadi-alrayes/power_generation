with joined as (
    select * from power_generation_DEV.O3_JOIN.join_power_generation
)

select
    -- Date dimension
    start_date_only as generation_date,
    start_year,
    start_month,
    start_day,

    -- Unit dimension
    power_generation_unit_id,
    unit_name,
    operator,
    unit_city,
    unit_state,
    unit_postal_code,
    energy_source,
    plant_status,
    voltage_level,
    is_storage,

    -- Unit capacity (takes latest value per day)
    max(gross_capacity_mw) as gross_capacity_mw,
    max(net_electrical_capacity_mw) as net_electrical_capacity_mw,

    -- Power generation aggregations
    count(*) as number_of_readings,
    sum(duration_hours) as total_duration_hours,
    sum(energy_mwh) as total_energy_mwh,
    avg(value_mw) as avg_power_mw,
    min(value_mw) as min_power_mw,
    max(value_mw) as max_power_mw,
    stddev(value_mw) as stddev_power_mw,

    -- Capacity utilization
    avg(capacity_utilization_pct) as avg_capacity_utilization_pct,
    min(capacity_utilization_pct) as min_capacity_utilization_pct,
    max(capacity_utilization_pct) as max_capacity_utilization_pct,

    -- Weather aggregations (daily averages)
    avg(temperature_2m_c) as avg_temperature_2m_c,
    min(temperature_2m_c) as min_temperature_2m_c,
    max(temperature_2m_c) as max_temperature_2m_c,

    avg(wind_speed_10m_m_s) as avg_wind_speed_10m_m_s,
    max(wind_speed_10m_m_s) as max_wind_speed_10m_m_s,

    avg(wind_speed_80m_m_s) as avg_wind_speed_80m_m_s,
    max(wind_speed_80m_m_s) as max_wind_speed_80m_m_s,

    avg(shortwave_radiation_w_m2) as avg_shortwave_radiation_w_m2,
    avg(direct_radiation_w_m2) as avg_direct_radiation_w_m2,
    avg(diffuse_radiation_w_m2) as avg_diffuse_radiation_w_m2,

    sum(precipitation_mm) as total_precipitation_mm,
    sum(rain_mm) as total_rain_mm,
    sum(snowfall_cm) as total_snowfall_cm,

    avg(cloud_cover) as avg_cloud_cover,
    avg(pressure_msl_hpa) as avg_pressure_msl_hpa,

    -- Location
    max(country_english) as country,
    max(latitude) as latitude,
    max(longitude) as longitude

from joined
group by
    start_date_only,
    start_year,
    start_month,
    start_day,
    power_generation_unit_id,
    unit_name,
    operator,
    unit_city,
    unit_state,
    unit_postal_code,
    energy_source,
    plant_status,
    voltage_level,
    is_storage