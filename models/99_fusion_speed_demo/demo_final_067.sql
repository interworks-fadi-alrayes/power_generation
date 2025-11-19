-- Fusion Speed Demo: Final Complex Model 067
with agg_1 as (
  select * from {{ ref('demo_agg_067') }}
),

agg_2 as (
  select * from {{ ref('demo_agg_093') }}
),

agg_3 as (
  select * from {{ ref('demo_agg_043') }}
),

final_metrics as (
  select
    coalesce(a1.generation_date, a2.generation_date, a3.generation_date) as generation_date,
    coalesce(a1.unit_name, a2.unit_name, a3.unit_name) as unit_name,
    coalesce(a1.unit_state, a2.unit_state, a3.unit_state) as unit_state,
    coalesce(a1.energy_source, a2.energy_source, a3.energy_source) as energy_source,
    a1.total_energy_a as energy_set_1,
    a2.total_energy_a as energy_set_2,
    a3.total_energy_a as energy_set_3,
    (coalesce(a1.record_count, 0) + coalesce(a2.record_count, 0) + coalesce(a3.record_count, 0)) as total_records,
    (coalesce(a1.unit_count, 0) + coalesce(a2.unit_count, 0) + coalesce(a3.unit_count, 0)) as total_units,
    case
      when a1.avg_rank < 10 then 'Top Tier'
      when a1.avg_rank < 50 then 'Middle Tier'
      else 'Lower Tier'
    end as performance_tier
  from agg_1 a1
  full outer join agg_2 a2
    on a1.generation_date = a2.generation_date
    and a1.unit_name = a2.unit_name
  full outer join agg_3 a3
    on a1.generation_date = a3.generation_date
    and a1.unit_name = a3.unit_name
)

select * from final_metrics
