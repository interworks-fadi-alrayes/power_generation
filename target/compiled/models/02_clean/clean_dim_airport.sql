with 

source as (

    select * from power_generation_dev.O1_raw.dim_airport

),

renamed as (

    select
        upper(trim(airportcode)) as airport_code,
        upper(trim(airportname)) as airport_name

    from source

)

select * from renamed