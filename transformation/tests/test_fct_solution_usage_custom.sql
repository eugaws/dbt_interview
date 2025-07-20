-- Custom test: Ensure all times_used values are non-negative

with invalid_times_used as (
    select solution_usage_key, times_used
    from {{ ref('fct_solution_usage') }}
    where times_used < 0
)

select * from invalid_times_used 