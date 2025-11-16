with fact as (
    select * from power_generation_DEV.O2_CLEAN.clean_fact_power_generation
),

units as (
    select * from power_generation_DEV.O2_CLEAN.clean_dim_unit
),

weather as (
    select * from power_generation_DEV.O2_CLEAN.clean_dim_weather
),

fact_parsed as (
    select
        power_generation_id,
        power_generation_unit_id,
        value_mw,

        -- Parse start_date from DD.MM.YYYY HH:MM format
        start_date,
        strptime(start_date, '%d.%m.%Y %H:%M') as start_datetime,

        -- Parse end_date from DD.MM.YYYY HH:MM format
        end_date,
        strptime(end_date, '%d.%m.%Y %H:%M') as end_datetime,

        -- Extract date components from start_date
        cast(strftime(strptime(start_date, '%d.%m.%Y %H:%M'), '%Y') as integer) as start_year,
        cast(strftime(strptime(start_date, '%d.%m.%Y %H:%M'), '%m') as integer) as start_month,
        cast(strftime(strptime(start_date, '%d.%m.%Y %H:%M'), '%d') as integer) as start_day,
        cast(strftime(strptime(start_date, '%d.%m.%Y %H:%M'), '%H') as integer) as start_hour,
        cast(strftime(strptime(start_date, '%d.%m.%Y %H:%M'), '%M') as integer) as start_minute,
        strftime(strptime(start_date, '%d.%m.%Y %H:%M'), '%Y-%m-%d') as start_date_only,

        -- Extract date components from end_date
        cast(strftime(strptime(end_date, '%d.%m.%Y %H:%M'), '%Y') as integer) as end_year,
        cast(strftime(strptime(end_date, '%d.%m.%Y %H:%M'), '%m') as integer) as end_month,
        cast(strftime(strptime(end_date, '%d.%m.%Y %H:%M'), '%d') as integer) as end_day,
        cast(strftime(strptime(end_date, '%d.%m.%Y %H:%M'), '%H') as integer) as end_hour,
        cast(strftime(strptime(end_date, '%d.%m.%Y %H:%M'), '%M') as integer) as end_minute,

        -- Calculate duration in hours
        extract(epoch from (strptime(end_date, '%d.%m.%Y %H:%M') - strptime(start_date, '%d.%m.%Y %H:%M'))) / 3600 as duration_hours

    from fact
),

weather_parsed as (
    select
        postal_code,
        time,
        cast(time as timestamp) as weather_datetime,

        -- Extract date components
        cast(strftime(cast(time as timestamp), '%Y') as integer) as weather_year,
        cast(strftime(cast(time as timestamp), '%m') as integer) as weather_month,
        cast(strftime(cast(time as timestamp), '%d') as integer) as weather_day,
        cast(strftime(cast(time as timestamp), '%H') as integer) as weather_hour,
        strftime(cast(time as timestamp), '%Y-%m-%d') as weather_date_only,

        -- Weather measurements
        temperature_2m_c,
        wind_speed_10m_m_s,
        wind_speed_80m_m_s,
        shortwave_radiation_w_m2,
        direct_radiation_w_m2,
        diffuse_radiation_w_m2,
        precipitation_mm,
        cloud_cover,
        pressure_msl_hpa,
        rain_mm,
        snowfall_cm,
        country_english,
        latitude,
        longitude

    from weather
)

select
    -- Fact identifiers
    fp.power_generation_id,
    fp.power_generation_unit_id,

    -- Unit information
    u.unit_name,
    u.operator,
    u.unit_street,
    u.unit_house_number,
    u.unit_postal_code,
    u.unit_city,
    u.unit_state,
    u.energy_source,
    u.is_storage,
    u.voltage_level,
    u.plant_status,
    u.commissioning_year,
    u.decommissioning_year,
    u.gross_capacity_mw,
    u.net_electrical_capacity_mw,
    u.is_cross_border_unit,
    u.feed_in_type,
    u.grid_operator,

    -- Power generation temporal data
    fp.start_date,
    fp.start_datetime,
    fp.start_year,
    fp.start_month,
    fp.start_day,
    fp.start_hour,
    fp.start_minute,
    fp.start_date_only,

    fp.end_date,
    fp.end_datetime,
    fp.end_year,
    fp.end_month,
    fp.end_day,
    fp.end_hour,
    fp.end_minute,

    fp.duration_hours,

    -- Power generation measurements
    fp.value_mw,

    -- Calculated metrics
    fp.value_mw * fp.duration_hours as energy_mwh,
    case
        when u.net_electrical_capacity_mw > 0
        then (fp.value_mw / u.net_electrical_capacity_mw) * 100
        else null
    end as capacity_utilization_pct,

    -- Weather data
    w.weather_datetime,
    w.weather_year,
    w.weather_month,
    w.weather_day,
    w.weather_hour,
    w.temperature_2m_c,
    w.wind_speed_10m_m_s,
    w.wind_speed_80m_m_s,
    w.shortwave_radiation_w_m2,
    w.direct_radiation_w_m2,
    w.diffuse_radiation_w_m2,
    w.precipitation_mm,
    w.cloud_cover,
    w.pressure_msl_hpa,
    w.rain_mm,
    w.snowfall_cm,
    w.country_english,
    w.latitude,
    w.longitude

from fact_parsed fp
left join units u
    on fp.power_generation_unit_id = u.power_generation_unit_id
left join weather_parsed w
    on u.unit_postal_code = w.postal_code
    and fp.start_datetime = w.weather_datetime