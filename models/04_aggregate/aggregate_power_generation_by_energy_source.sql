with joined as (
  select
    *
  from {{ ref('join_power_generation') }}
)

select
  -- Time dimension
  start_year,
  start_month,

  -- Energy source dimension
  energy_source,

  -- Power generation metrics
  count(distinct power_generation_unit_id) as number_of_units,
  sum(duration_hours) as total_duration_hours,
  sum(energy_mwh) as total_energy_mwh,
  avg(value_mw) as avg_power_mw,
  max(value_mw) as max_power_mw,


from joined
group by
  start_year,
  start_month,
  energy_source
