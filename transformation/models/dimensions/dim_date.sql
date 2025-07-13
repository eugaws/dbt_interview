{{
  config(
    materialized='table',
    unique_key='date_key'
  )
}}

with date_spine as (
    {{ dbt_date.get_date_dimension('2015-01-01', '2030-12-31') }}
),

final as (
    select
        -- Primary Key
        date_day as date_key,
        
        -- Date Information
        date_day as date_actual,
        year_number as year_actual,
        quarter_of_year as quarter_actual,
        month_of_year as month_actual,
        week_of_year as week_actual,
        day_of_month as day_actual,
        day_of_year,
        day_of_week,
        
        -- Date Formatted
        date_day::varchar as date_formatted,
        year_number || '-' || lpad(month_of_year::varchar, 2, '0') as year_month,
        year_number || '-Q' || quarter_of_year::varchar as year_quarter,
        month_name || ' ' || year_number::varchar as month_name_year,
        'Q' || quarter_of_year::varchar || ' ' || year_number::varchar as quarter_name_year,
        
        -- Month Information
        month_name,
        month_name_short,
        month_name as month_name_full,
        
        -- Day Information
        day_of_week_name as day_name,
        day_of_week_name_short as day_name_short,
        day_of_week_name as day_name_full,
        
        -- Business Day Information
        case 
            when day_of_week in (1, 7) then false
            else true
        end as is_weekday,
        
        case 
            when day_of_week in (1, 7) then true
            else false
        end as is_weekend,
        
        -- Fiscal Year (assuming fiscal year starts in January)
        year_number as fiscal_year,
        quarter_of_year as fiscal_quarter,
        
        -- Relative Date Information
        case 
            when date_day = current_date then 'Today'
            when date_day = current_date - interval '1 day' then 'Yesterday'
            when date_day = current_date + interval '1 day' then 'Tomorrow'
            when date_day between current_date - interval '7 days' and current_date - interval '1 day' then 'Past Week'
            when date_day between current_date + interval '1 day' and current_date + interval '7 days' then 'Next Week'
            when date_day between current_date - interval '30 days' and current_date - interval '1 day' then 'Past Month'
            when date_day between current_date + interval '1 day' and current_date + interval '30 days' then 'Next Month'
            when date_day < current_date then 'Past'
            else 'Future'
        end as relative_date,
        
        -- Date Flags
        case when date_day <= current_date then true else false end as is_past,
        case when date_day = current_date then true else false end as is_current,
        case when date_day >= current_date then true else false end as is_future,
        
        -- Start/End of Period Flags
        case when day_of_month = 1 then true else false end as is_month_start,
        case when date_day = month_end_date then true else false end as is_month_end,
        case when day_of_year = 1 then true else false end as is_year_start,
        case when date_day = year_end_date then true else false end as is_year_end,
        
        current_timestamp as dbt_updated_at
        
    from date_spine
)

select * from final 