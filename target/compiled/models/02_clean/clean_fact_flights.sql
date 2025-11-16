with 

source as (
    select * from power_generation_dev.O1_raw.fact_power_generation
),

renamed as (
    select
        transactionid as transaction_id,
        dayofweek as day_of_week,
        flightdate as flight_date,
        upper(trim(airlineid)) as airline_id,
        uniquecarrier as unique_carrier,
        carrier as carrier,
        tailnum as tail_num,
        flightnum as flight_num,
        upper(trim(originairportid)) as origin_airport_id,
        upper(trim(originairportcode)) as origin_airport_code,
        origincityname as origin_city_name,
        originstate as origin_state,
        originstatename as origin_state_name,
        upper(trim(destairportcode)) as dest_airport_code,
        destcityname as dest_city_name,
        deststate as dest_state,
        deststatename as dest_state_name,
        crsdeptime as crs_dep_time,
        deptime as dep_time,
        depdelay as dep_delay,
        depdelayminutes as dep_delay_minutes,
        depdel15 as dep_del_15,
        departuredelaygroups as departure_delay_groups,
        deptimeblk as dep_time_blk,
        taxiout as taxi_out,
        wheelsoff as wheels_off,
        wheelson as wheels_on,
        taxiin as taxi_in,
        crsarrtime as crs_arr_time,
        arrtime as arr_time,
        arrdelay as arr_delay,
        arrdelayminutes as arr_delay_minutes,
        arrdel15 as arr_del_15,
        arrivaldelaygroups as arrival_delay_groups,
        arrtimeblk as arr_time_blk,
        cancelled as cancelled,
        cancellationcode as cancellation_code,
        diverted as diverted,
        crselapsedtime as crs_elapsed_time,
        actualelapsedtime as actual_elapsed_time,
        airtime as air_time,
        power_generation as power_generation,
        distance as distance,
        distancegroupid as distance_group_id,
        carrierdelay as carrier_delay,
        weatherdelay as weather_delay,
        nasdelay as nas_delay,
        securitydelay as security_delay,
        lateaircraftdelay as late_aircraft_delay,
        firstdeptime as first_dep_time,
        totaladdgtime as total_add_g_time,
        longestaddgtime as longest_add_g_time,
        flightdivertedcount as flight_diverted_count,

        -- Binned distance category
        case
            when distance is null then 'Unknown'
            when distance < 250 then 'Short Flight (<250 mi)'
            when distance >= 250 and distance < 750 then 'Medium Flight (250-749 mi)'
            when distance >= 750 and distance < 1500 then 'Long Flight (750-1499 mi)'
            when distance >= 1500 then 'Ultra Long Flight (1500+ mi)'
        end as distance_category

    from source
)

select * from renamed