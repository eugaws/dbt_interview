{{
  config(
    materialized='table',
    unique_key='case_resolution_key'
  )
}}

with resolved_cases as (
    select * from {{ ref('stg_salesforce__case') }}
    where not isdeleted 
    and isclosed = true
    and closeddate is not null
    and createddate is not null
    and closeddate >= createddate  -- Only include cases where close date is after create date
),

final as (
    select
        -- Primary Key
        case_id || '_resolution' as case_resolution_key,
        
        -- Foreign Keys (Dimension References)
        case_id as case_key,
        accountid as account_key,
        contactid as contact_key,
        ownerid as owner_key,
        createdbyid as created_by_key,
        productid as product_key,
        
        -- Date Foreign Keys
        date(closeddate) as resolution_date_key,
        date(createddate) as case_created_date_key,
        
        -- Resolution Event Information
        closeddate as resolution_date,
        createddate as case_created_date,
        
        -- Key Metrics (Measures)
        datediff('day', createddate, closeddate) as days_to_resolution,
        datediff('hour', createddate, closeddate) as hours_to_resolution,
        
        -- Resolution Counts (for aggregation)
        1 as resolution_count,
        case when isescalated then 1 else 0 end as escalated_count,
        
        -- Business Logic (Derived Measures)
        case 
            when datediff('day', createddate, closeddate) <= 1 then 'Same Day'
            when datediff('day', createddate, closeddate) <= 3 then 'Within 3 Days'
            when datediff('day', createddate, closeddate) <= 7 then 'Within 1 Week'
            when datediff('day', createddate, closeddate) <= 30 then 'Within 1 Month'
            else 'Over 1 Month'
        end as resolution_speed,
        
        -- Priority-based SLA Performance
        case 
            when priority = '1' and datediff('day', createddate, closeddate) <= 1 then 'Met SLA'
            when priority = '2' and datediff('day', createddate, closeddate) <= 3 then 'Met SLA'
            when priority = '3' and datediff('day', createddate, closeddate) <= 7 then 'Met SLA'
            when priority = '4' and datediff('day', createddate, closeddate) <= 14 then 'Met SLA'
            else 'Missed SLA'
        end as sla_performance,
        
        -- Priority Scoring (for weighted analysis)
        case 
            when priority = '1' then 4
            when priority = '2' then 3
            when priority = '3' then 2
            when priority = '4' then 1
            else 0
        end as priority_score,
        
        -- Resolution Quality Indicators
        case 
            when not isescalated and datediff('day', createddate, closeddate) <= 7 then 'High Quality'
            when not isescalated and datediff('day', createddate, closeddate) <= 14 then 'Good Quality'
            when isescalated or datediff('day', createddate, closeddate) > 14 then 'Poor Quality'
            else 'Unknown'
        end as resolution_quality,
        
        -- Workload Indicators
        case 
            when extract(dow from createddate) in (0, 6) then 'Weekend'
            else 'Weekday'
        end as created_day_type,
        
        case 
            when extract(dow from closeddate) in (0, 6) then 'Weekend'
            else 'Weekday'
        end as resolved_day_type,
        
        current_timestamp as dbt_updated_at
        
    from resolved_cases
)

select * from final 