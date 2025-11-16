with 

source as (

    select * from power_generation_dev.O1_raw.dim_airline

),

renamed as (

    select
        upper(trim(airlineid)) as airline_id,
        upper(trim(airlinename)) as airline_name

    from source

)

select * from renamed