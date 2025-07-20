{{
  config(
    materialized='table'
  )
}}

with accounts as (
    select * from {{ ref('stg_salesforce__account') }}
    where not isdeleted
),

final as (
    select
        -- Primary Key
        account_id as account_key,

        -- Account Information
        name as account_name,
        type as account_type,
        industry,
        annualrevenue as annual_revenue,
        numberofemployees as number_of_employees,

        -- Custom Business Fields
        customerpriority__c as customer_priority,
        sla__c as sla,
        active__c as active,
        numberoflocations__c as number_of_locations,
        upsellopportunity__c as upsell_opportunity,
        slaserialnumber__c as sla_serial_number,
        slaexpirationdate__c as sla_expiration_date,

        -- Location Information
        billingcountry as billing_country,
        shippingcountry as shipping_country,

        createddate as created_at,
        lastmodifieddate as last_modified_at,

        -- Derived Categories
        systemmodstamp as system_modified_at,

        case
            when upper(billingcountry) in ('USA', 'US', 'UNITED STATES') then 'United States'
            when upper(billingcountry) = 'FRANCE' then 'France'
            else 'Unknown'
        end as billing_country_clean,

        case
            when upper(shippingcountry) in ('USA', 'US', 'UNITED STATES') then 'United States'
            when upper(shippingcountry) = 'FRANCE' then 'France'
            else 'Unknown'
        end as shipping_country_clean,

        case
            when coalesce(annualrevenue, 0) >= 100000000 then 'Enterprise'
            when coalesce(annualrevenue, 0) >= 10000000 then 'Large'
            when coalesce(annualrevenue, 0) >= 1000000 then 'Mid-Market'
            when coalesce(annualrevenue, 0) >= 100000 then 'Small'
            when coalesce(annualrevenue, 0) >= 10000 then 'Micro'
            when coalesce(annualrevenue, 0) >= 1000 then 'Very Small'
            else 'Unknown'
        end as company_size_segment,

        -- Timestamps
        case
            when coalesce(numberofemployees, 0) >= 10000 then 'Enterprise'
            when coalesce(numberofemployees, 0) >= 1000 then 'Large'
            when coalesce(numberofemployees, 0) >= 100 then 'Mid-Market'
            when coalesce(numberofemployees, 0) >= 10 then 'Small'
            when coalesce(numberofemployees, 0) >= 1 then 'Micro'
            else 'Very Small'
        end as employee_size_segment,
        case
            when upper(industry) like '%TECH%' or upper(industry) like '%SOFTWARE%' then 'Technology'
            when upper(industry) like '%SERVICE%' then 'Services'
            when upper(industry) like '%CONSULT%' or upper(industry) like '%PROFESSIONAL%' then 'Professional Services'
            when upper(industry) like '%MANUFACT%' then 'Manufacturing'
            when industry is not null then 'Other'
            else 'Unknown'
        end as industry_category,
        case
            when upper(billingcountry) = 'UNITED STATES' and upper(shippingcountry) = 'UNITED STATES' then 'Domestic'
            when
                upper(billingcountry) != 'UNITED STATES' or upper(shippingcountry) != 'UNITED STATES'
                then 'International'
            else 'Unknown'
        end as account_scope,

        current_timestamp as dbt_updated_at

    from accounts
)

select * from final
