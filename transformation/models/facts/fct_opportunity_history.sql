{{
  config(
    materialized='table'
  )
}}

with opportunity_history as (
    select * from {{ ref('stg_salesforce__opportunity_history') }}
    where not isdeleted
),

-- Get opportunity details for context
opportunities as (
    select * from {{ ref('stg_salesforce__opportunity') }}
    where not isdeleted
),

-- Join with opportunity data to get additional context
enriched_history as (
    select
        oh.*,
        o.accountid,
        o.ownerid,
        o.campaignid,
        o.contactid,
      --  o.type as opportunity_type,
      --  o.leadsource as lead_source,
        o.isclosed,
        o.iswon
    from opportunity_history oh
    left join opportunities o on oh.opportunityid = o.opportunity_id
),

final as (
    select
        -- Primary Key
        opportunity_history_id as opportunity_history_key,
        
        -- Foreign Keys (Dimension References)
        opportunityid as opportunity_key,
        accountid as account_key,
        case when contactid = '000000000000000AAA' then null else contactid end as contact_key,
        ownerid as owner_key,
        campaignid as campaign_key,
        createdbyid as created_by_key,
        
        -- Date Foreign Keys using dbt_date
        date(createddate) as created_date_key,
        date(closedate) as close_date_key,
        date(validthroughdate) as valid_through_date_key,
        date(prevforecastupdate) as prev_forecast_update_date_key,
        
        -- Current Values (at time of history event)
        cast(amount as decimal(15,2)) as amount,
        coalesce(cast(amount as decimal(15,2)), 0.0) as amount_clean,
        cast(expectedrevenue as decimal(15,2)) as expected_revenue,
        coalesce(cast(expectedrevenue as decimal(15,2)), 0.0) as expected_revenue_clean,
        cast(probability as decimal(5,2)) as probability,
        coalesce(cast(probability as decimal(5,2)), 0.0) as probability_clean,
        
        -- Previous Values (before the change)
        cast(prevamount as decimal(15,2)) as prev_amount,
        coalesce(cast(prevamount as decimal(15,2)), 0.0) as prev_amount_clean,
        cast(prevclosedate as timestamp) as prev_close_date,
        
        -- Change Detection Flags
        case 
            when fromopportunitystagename is not null and fromopportunitystagename != stagename then 1 
            else 0 
        end as stage_change_count,
        
        case 
            when prevamount is not null and cast(prevamount as decimal(15,2)) != cast(amount as decimal(15,2)) then 1 
            else 0 
        end as amount_change_count,
        
        case 
            when prevclosedate is not null and cast(prevclosedate as timestamp) != cast(closedate as timestamp) then 1 
            else 0 
        end as close_date_change_count,
        
        case 
            when fromforecastcategory is not null and fromforecastcategory != forecastcategory then 1 
            else 0 
        end as forecast_change_count,
        
        -- Change Type Classification

        -- One Hot Encoding for change_type
        case when (
            fromopportunitystagename is not null and fromopportunitystagename != stagename
        ) then 1 else 0 end as is_stage_change,
        case when (
            prevamount is not null and cast(prevamount as decimal(15,2)) != cast(amount as decimal(15,2))
        ) then 1 else 0 end as is_amount_change,
        case when (
            prevclosedate is not null and cast(prevclosedate as timestamp) != cast(closedate as timestamp)
        ) then 1 else 0 end as is_close_date_change,
        case when (
            fromforecastcategory is not null and fromforecastcategory != forecastcategory
        ) then 1 else 0 end as is_forecast_change,
        case when not (
            (fromopportunitystagename is not null and fromopportunitystagename != stagename)
            or (prevamount is not null and cast(prevamount as decimal(15,2)) != cast(amount as decimal(15,2)))
            or (prevclosedate is not null and cast(prevclosedate as timestamp) != cast(closedate as timestamp))
            or (fromforecastcategory is not null and fromforecastcategory != forecastcategory)
        ) then 1 else 0 end as is_other_change,
        
        -- Calculated Measures
        case 
            when amount is not null and probability is not null then 
                round((cast(amount as decimal(15,2)) * cast(probability as decimal(5,2)) / 100), 2)
            else 0.0
        end as weighted_amount,
        
        case 
            when prevamount is not null and amount is not null then 
                cast(amount as decimal(15,2)) - cast(prevamount as decimal(15,2))
            else 0.0
        end as amount_change,
        
        case 
            when prevamount is not null and amount is not null and cast(prevamount as decimal(15,2)) > 0 then 
                round(((cast(amount as decimal(15,2)) - cast(prevamount as decimal(15,2))) / cast(prevamount as decimal(15,2)) * 100), 2)
            else 0.0
        end as amount_change_percentage,
        
        -- Event Counts (for aggregation)
        1 as history_event_count,
        
        -- Stage Progression Indicators
        case 
            when upper(stagename) like '%CLOSED%' and upper(fromopportunitystagename) not like '%CLOSED%' then 1
            else 0
        end as stage_to_closed_count,
        
        case 
            when upper(stagename) like '%WON%' and upper(fromopportunitystagename) not like '%WON%' then 1
            else 0
        end as stage_to_won_count,
        
        -- Time-based Measures
        case 
            when prevclosedate is not null and closedate is not null then 
                datediff('day', cast(prevclosedate as timestamp), closedate)
            else null
        end as days_close_date_changed,
        
        case 
            when createddate is not null then 
                datediff('day', createddate, current_date)
            else null
        end as days_since_history_event,
        
        -- Context Information

        isclosed,
        iswon,
        
        -- Timestamps
        createddate as created_at,
        closedate as close_date,
        validthroughdate as valid_through_date,
        prevforecastupdate as prev_forecast_update,
        systemmodstamp as system_modified_at,
        
        current_timestamp as dbt_updated_at
        
    from enriched_history
)

select * from final 