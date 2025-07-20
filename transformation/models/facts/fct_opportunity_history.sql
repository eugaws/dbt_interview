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
        o.type as opportunity_type,
        o.leadsource as lead_source,
        o.isclosed,
        o.iswon
    from opportunity_history as oh
    left join opportunities as o on oh.opportunityid = o.opportunity_id
),

final as (
    select
        -- Primary Key
        opportunity_history_id as opportunity_history_key,

        -- Foreign Keys (Dimension References)
        opportunityid as opportunity_key,
        accountid as account_key,
        ownerid as owner_key,
        campaignid as campaign_key,
        createdbyid as created_by_key,
        cast(amount as decimal(15, 2)) as amount,

        -- Date Foreign Keys using dbt_date
        cast(expectedrevenue as decimal(15, 2)) as expected_revenue,
        cast(probability as decimal(5, 2)) as probability,
        cast(prevamount as decimal(15, 2)) as prev_amount,
        cast(prevclosedate as timestamp) as prev_close_date,

        -- Current Values (at time of history event)
        1 as history_event_count,
        opportunity_type,
        lead_source,
        isclosed,
        iswon,
        createddate as created_at,

        -- Previous Values (before the change)
        closedate as close_date,
        validthroughdate as valid_through_date,
        prevforecastupdate as prev_forecast_update,

        -- Change Detection Flags
        systemmodstamp as system_modified_at,

        case when contactid = '000000000000000AAA' then null else contactid end as contact_key,

        date(createddate) as created_date_key,

        date(closedate) as close_date_key,

        -- Change Type Classification
        date(validthroughdate) as valid_through_date_key,

        -- Calculated Measures
        date(prevforecastupdate) as prev_forecast_update_date_key,

        coalesce(cast(amount as decimal(15, 2)), 0.0) as amount_clean,

        coalesce(cast(expectedrevenue as decimal(15, 2)), 0.0) as expected_revenue_clean,

        -- Event Counts (for aggregation)
        coalesce(cast(probability as decimal(5, 2)), 0.0) as probability_clean,

        -- Stage Progression Indicators
        coalesce(cast(prevamount as decimal(15, 2)), 0.0) as prev_amount_clean,

        case
            when fromopportunitystagename is not null and fromopportunitystagename != stagename then 1
            else 0
        end as stage_change_count,

        -- Time-based Measures
        case
            when prevamount is not null and cast(prevamount as decimal(15, 2)) != cast(amount as decimal(15, 2)) then 1
            else 0
        end as amount_change_count,

        case
            when prevclosedate is not null and cast(prevclosedate as timestamp) != cast(closedate as timestamp) then 1
            else 0
        end as close_date_change_count,

        -- Context Information
        case
            when fromforecastcategory is not null and fromforecastcategory != forecastcategory then 1
            else 0
        end as forecast_change_count,
        case
            when fromopportunitystagename is not null and fromopportunitystagename != stagename then 'Stage Change'
            when
                prevamount is not null and cast(prevamount as decimal(15, 2)) != cast(amount as decimal(15, 2))
                then 'Amount Change'
            when
                prevclosedate is not null and cast(prevclosedate as timestamp) != cast(closedate as timestamp)
                then 'Close Date Change'
            when fromforecastcategory is not null and fromforecastcategory != forecastcategory then 'Forecast Change'
            else 'Other Change'
        end as change_type,
        case
            when amount is not null and probability is not null
                then
                    round((cast(amount as decimal(15, 2)) * cast(probability as decimal(5, 2)) / 100), 2)
            else 0.0
        end as weighted_amount,
        case
            when prevamount is not null and amount is not null
                then
                    cast(amount as decimal(15, 2)) - cast(prevamount as decimal(15, 2))
            else 0.0
        end as amount_change,

        -- Timestamps
        case
            when prevamount is not null and amount is not null and cast(prevamount as decimal(15, 2)) > 0
                then
                    round(
                        (
                            (cast(amount as decimal(15, 2)) - cast(prevamount as decimal(15, 2)))
                            / cast(prevamount as decimal(15, 2))
                            * 100
                        ),
                        2
                    )
            else 0.0
        end as amount_change_percentage,
        case
            when upper(stagename) like '%CLOSED%' and upper(fromopportunitystagename) not like '%CLOSED%' then 1
            else 0
        end as stage_to_closed_count,
        case
            when upper(stagename) like '%WON%' and upper(fromopportunitystagename) not like '%WON%' then 1
            else 0
        end as stage_to_won_count,
        case
            when prevclosedate is not null and closedate is not null
                then
                    datediff('day', cast(prevclosedate as timestamp), closedate)
        end as days_close_date_changed,
        case
            when createddate is not null
                then
                    datediff('day', createddate, current_date)
        end as days_since_history_event,

        current_timestamp as dbt_updated_at

    from enriched_history
)

select * from final
