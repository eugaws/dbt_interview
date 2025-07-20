{{
  config(
    materialized='table'
  )
}}

with opportunities as (
    select * from {{ ref('stg_salesforce__opportunity') }}
    where not isdeleted
),

final as (
    select
        -- Primary Key
        opportunity_id as opportunity_key,

        -- Foreign Keys (Dimension References)
        accountid as account_key,
        contactid as contact_id,
        ownerid as owner_key,
        campaignid as campaign_id,
        pricebook2id as pricebook_key,
        createdbyid as created_by_key,
        lastmodifiedbyid as last_modified_by_key,

        -- Date Foreign Keys
        name as opportunity_name,
        description,
        type as opportunity_type,
        stagename as stage_name,
        stagesortorder as stage_sort_order,

        -- Opportunity Descriptive Information
        leadsource as lead_source,
        nextstep as next_step,
        amount,
        probability,
        expectedrevenue as expected_revenue,
        totalopportunityquantity as total_opportunity_quantity,
        isclosed as is_closed,

        -- Financial Information
        iswon as is_won,
        forecastcategory as forecast_category,
        forecastcategoryname as forecast_category_name,
        fiscalyear as fiscal_year,

        -- Status Information
        fiscalquarter as fiscal_quarter,
        deliveryinstallationstatus__c as delivery_installation_status,
        trackingnumber__c as tracking_number,

        -- Forecast Information
        ordernumber__c as order_number,
        currentgenerators__c as current_generators,
        maincompetitors__c as main_competitors,
        closedate as close_date,

        -- Custom Fields
        createddate as created_at,
        lastmodifieddate as last_modified_at,
        laststagechangedate as last_stage_change_at,
        lastactivitydate as last_activity_at,
        date(closedate) as close_date_key,

        -- Derived Categories (Dimension Attributes)
        date(createddate) as created_date_key,

        date(lastmodifieddate) as last_modified_date_key,

        date(laststagechangedate) as last_stage_change_date_key,

        date(lastactivitydate) as last_activity_date_key,

        case
            when iswon then 'Won'
            when isclosed and not iswon then 'Lost'
            else 'Open'
        end as opportunity_status,

        case
            when coalesce(cast(amount as decimal(15, 2)), 0) >= 1000000 then 'Large Deal'
            when coalesce(cast(amount as decimal(15, 2)), 0) >= 100000 then 'Medium Deal'
            when coalesce(cast(amount as decimal(15, 2)), 0) >= 10000 then 'Small Deal'
            else 'Micro Deal'
        end as deal_size_category,

        -- Dates
        case
            when coalesce(cast(probability as decimal(5, 2)), 0) >= 80 then 'High Probability'
            when coalesce(cast(probability as decimal(5, 2)), 0) >= 50 then 'Medium Probability'
            when coalesce(cast(probability as decimal(5, 2)), 0) >= 20 then 'Low Probability'
            else 'Very Low Probability'
        end as probability_category,
        case
            when closedate < current_date and not isclosed then 'Overdue'
            when closedate <= current_date + interval '30 days' and not isclosed then 'Closing Soon'
            when closedate <= current_date + interval '90 days' and not isclosed then 'This Quarter'
            else 'Future'
        end as timeline_category,
        case
            when upper(stagename) like '%PROSPECT%' or upper(stagename) like '%QUALIFICATION%' then 'Early Stage'
            when upper(stagename) like '%PROPOSAL%' or upper(stagename) like '%NEGOTIATION%' then 'Advanced Stage'
            when upper(stagename) like '%CLOSED%' then 'Closed'
            else 'Mid Stage'
        end as stage_category,
        case
            when upper(type) like '%NEW%' then 'New Business'
            when upper(type) like '%EXISTING%' or upper(type) like '%UPSELL%' then 'Existing Business'
            when upper(type) like '%RENEWAL%' then 'Renewal'
            else 'Other'
        end as business_type,
        case
            when upper(leadsource) like '%WEB%' or upper(leadsource) like '%ONLINE%' then 'Digital'
            when upper(leadsource) like '%REFERRAL%' then 'Referral'
            when upper(leadsource) like '%COLD%' or upper(leadsource) like '%OUTBOUND%' then 'Outbound'
            when upper(leadsource) like '%TRADE%' or upper(leadsource) like '%EVENT%' then 'Events'
            else 'Other'
        end as lead_source_category,

        current_timestamp as dbt_updated_at

    from opportunities
)

select * from final
