-- Fusion Speed Demo: Intermediate Model 040
with data_a as (
  select * from {{ ref('demo_base_040') }}
),

data_b as (
  select * from {{ ref('demo_base_074') }}
),

joined as (
  select
    a.generation_date,
    a.power_generation_unit_id,
    a.unit_name,
    a.unit_state,
    a.energy_source,
    a.total_energy_mwh as energy_a,
    b.total_energy_mwh as energy_b,
    a.total_energy_mwh + coalesce(b.total_energy_mwh, 0) as total_energy,
    a.avg_temperature_2m_c,
    b.avg_wind_speed_10m_mps,
    row_number() over (partition by a.generation_date order by a.total_energy_mwh desc) as daily_rank
  from data_a a
  left join data_b b
    on a.generation_date = b.generation_date
    and a.power_generation_unit_id = b.power_generation_unit_id
)

select * from joined
