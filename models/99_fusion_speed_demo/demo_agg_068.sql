-- Fusion Speed Demo: Aggregation Model 068
with int_a as (
  select * from {{ ref('demo_intermediate_068') }}
),

int_b as (
  select * from {{ ref('demo_intermediate_019') }}
),

aggregated as (
  select
    a.generation_date,
    a.unit_name,
    a.unit_state,
    a.energy_source,
    sum(a.energy_a) as total_energy_a,
    sum(b.energy_b) as total_energy_b,
    avg(a.daily_rank) as avg_rank,
    max(a.total_energy) as max_total_energy,
    count(distinct a.power_generation_unit_id) as unit_count,
    count(*) as record_count
  from int_a a
  left join int_b b
    on a.generation_date = b.generation_date
    and a.power_generation_unit_id = b.power_generation_unit_id
  group by a.generation_date, a.unit_name, a.unit_state, a.energy_source
)

select * from aggregated
