with base as (
    select * from power_generation_DEV.O3_JOIN.join_power_generation
    where flight_date is not null
),

filtered_power_generation as (
    -- Only include valid, non-cancelled, non-diverted power_generation for delay metrics
    select *
    from base
    where cancelled = 0 and diverted = 0
),

aggregated as (
    select
        airline_name,
        origin_airport_name,
        dest_airport_name,
        distance_category,
        count(*) as total_power_generation,
        round(avg(dep_delay), 2) as avg_dep_delay,
        round(avg(arr_delay), 2) as avg_arr_delay,
        round(avg(distance), 2) as avg_distance,
        round(avg(air_time), 2) as avg_air_time,
        -- % of power_generation delayed more than 15 mins
        round(100.0 * sum(case when arr_delay > 15 then 1 else 0 end) / count(*), 2) as percent_delayed_power_generation
    from filtered_power_generation
    group by
        airline_name,
        origin_airport_name,
        dest_airport_name,
        distance_category
),

cancelled_stats as (
    select
        airline_name,
        origin_airport_name,
        dest_airport_name,
        distance_category,
        count(*) as cancelled_power_generation
    from base
    where cancelled = 1
    group by
        airline_name,
        origin_airport_name,
        dest_airport_name,
        distance_category
),

diverted_stats as (
    select
        airline_name,
        origin_airport_name,
        dest_airport_name,
        distance_category,
        count(*) as diverted_power_generation
    from base
    where diverted = 1
    group by
        airline_name,
        origin_airport_name,
        dest_airport_name,
        distance_category
)

-- Final output with joins
select
    a.*,
    coalesce(c.cancelled_power_generation, 0) as cancelled_power_generation,
    coalesce(d.diverted_power_generation, 0) as diverted_power_generation
from aggregated a
left join cancelled_stats c
    on a.airline_name = c.airline_name
    and a.origin_airport_name = c.origin_airport_name
    and a.dest_airport_name = c.dest_airport_name
    and a.distance_category = c.distance_category
left join diverted_stats d
    on a.airline_name = d.airline_name
    and a.origin_airport_name = d.origin_airport_name
    and a.dest_airport_name = d.dest_airport_name
    and a.distance_category = d.distance_category