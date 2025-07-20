{{
  config(
    materialized='table',
    unique_key='campaign_effectiveness_key'
  )
}}

with campaigns as (
    select * from {{ ref('stg_salesforce__campaign') }}
    where not isdeleted
),

final as (
    select
        -- Primary Key
        campaign_id as campaign_key,

        -- Foreign Keys
        ownerid as owner_key,
        createdbyid as created_by_key,

        isactive as is_active,


        -- Campaign Info
        parentid as parent_campaign_id,
        createddate as created_at,
        lastmodifieddate as last_modified_at,
        lastactivitydate as last_activity_at,
        campaign_id || '_' || coalesce(cast(createddate as varchar), 'no_date') as campaign_effectiveness_key,
        date(createddate) as created_date_key,

        -- One-hot encoding for campaign_type
        date(lastmodifieddate) as last_modified_date_key,
        date(startdate) as start_date_key,
        date(enddate) as end_date_key,
        case when lower(type) = 'webinar' then 1 else 0 end as campaign_type_webinar_flg,
        case when lower(type) = 'conference' then 1 else 0 end as campaign_type_conference_flg,
        case when lower(type) = 'email' then 1 else 0 end as campaign_type_email_flg,
        case when lower(type) = 'advertisement' then 1 else 0 end as campaign_type_advertisement_flg,

        -- One-hot encoding for campaign_status
        case when lower(type) = 'trade show' then 1 else 0 end as campaign_type_tradeshow_flg,
        case when lower(type) = 'direct mail' then 1 else 0 end as campaign_type_directmail_flg,
        case when lower(type) = 'other' then 1 else 0 end as campaign_type_other_flg,
        case when lower(status) = 'planned' then 1 else 0 end as campaign_status_planned_flg,
        case when lower(status) = 'in progress' then 1 else 0 end as campaign_status_inprogress_flg,

        -- One-hot encoding for is_active
        case when lower(status) = 'completed' then 1 else 0 end as campaign_status_completed_flg,

        -- Metrics
        case when lower(status) = 'aborted' then 1 else 0 end as campaign_status_aborted_flg,
        case when lower(status) = 'cancelled' then 1 else 0 end as campaign_status_cancelled_flg,
        case when isactive = true then 1 else 0 end as is_active,
        coalesce(numbersent, 0) as number_sent,
        coalesce(numberofleads, 0) as number_of_leads,
        coalesce(numberofconvertedleads, 0) as number_of_converted_leads,
        coalesce(numberofcontacts, 0) as number_of_contacts,
        coalesce(numberofresponses, 0) as number_of_responses,
        coalesce(numberofopportunities, 0) as number_of_opportunities,
        coalesce(numberofwonopportunities, 0) as number_of_won_opportunities,
        coalesce(amountallopportunities, 0.0) as amount_all_opportunities,
        coalesce(amountwonopportunities, 0.0) as amount_won_opportunities,

        -- Effectiveness Metrics
        coalesce(expectedrevenue, 0.0) as expected_revenue,
        coalesce(budgetedcost, 0.0) as budgeted_cost,
        coalesce(actualcost, 0.0) as actual_cost,
        case when coalesce(numberofleads, 0) > 0 then coalesce(actualcost, 0.0) / numberofleads end
            as cost_per_lead,
        case
            when coalesce(numberofopportunities, 0) > 0 then coalesce(actualcost, 0.0) / numberofopportunities
        end as cost_per_opportunity,
        case
            when coalesce(numberofwonopportunities, 0) > 0 then coalesce(actualcost, 0.0) / numberofwonopportunities
        end as cost_per_won_opportunity,

        -- Hierarchy Metrics (optional)
        case
            when coalesce(numberofleads, 0) > 0 then coalesce(numberofconvertedleads, 0) * 1.0 / numberofleads
        end as lead_conversion_rate,
        case
            when
                coalesce(numberofopportunities, 0) > 0
                then coalesce(numberofwonopportunities, 0) * 1.0 / numberofopportunities
        end as win_rate,
        case
            when coalesce(actualcost, 0.0) > 0 then (coalesce(amountwonopportunities, 0.0) - actualcost) / actualcost
        end as roi,
        coalesce(hierarchynumberofleads, 0) as hierarchy_number_of_leads,
        coalesce(hierarchynumberofconvertedleads, 0) as hierarchy_number_of_converted_leads,
        coalesce(hierarchynumberofcontacts, 0) as hierarchy_number_of_contacts,
        coalesce(hierarchynumberofresponses, 0) as hierarchy_number_of_responses,
        coalesce(hierarchynumberofopportunities, 0) as hierarchy_number_of_opportunities,
        coalesce(hierarchynumberofwonopportunities, 0) as hierarchy_number_of_won_opportunities,
        coalesce(hierarchyamountallopportunities, 0.0) as hierarchy_amount_all_opportunities,
        coalesce(hierarchyamountwonopportunities, 0.0) as hierarchy_amount_won_opportunities,
        coalesce(hierarchynumbersent, 0) as hierarchy_number_sent,

        -- Timestamps
        coalesce(hierarchyexpectedrevenue, 0.0) as hierarchy_expected_revenue,
        coalesce(hierarchybudgetedcost, 0.0) as hierarchy_budgeted_cost,
        coalesce(hierarchyactualcost, 0.0) as hierarchy_actual_cost,
        current_timestamp as dbt_updated_at

    from campaigns
)

select * from final
