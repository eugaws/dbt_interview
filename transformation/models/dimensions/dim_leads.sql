{{
  config(
    materialized='table'
  )
}}

with leads as (
    select * from {{ ref('stg_salesforce__lead') }}
    where not isdeleted
),

final as (
    select
        -- Primary Key
        lead_id as lead_key,
        
        -- Lead Information
        firstname as first_name,
        lastname as last_name,
        concat(firstname, ' ', lastname) as full_name,
        email,
        phone,
        mobilephone as mobile_phone,
        title,
        company,
        
        -- Lead Details
        leadsource as lead_source,
        status as lead_status,
        rating,
        description,
        
        -- Address Information
        street,
        city,
        state,
        postalcode as postal_code,
        country,
        
        -- Conversion Information
        isconverted as is_converted,
        converteddate as converted_date,
        convertedopportunityid as converted_opportunity_id,
        convertedaccountid as converted_account_id,
        convertedcontactid as converted_contact_id,
        
        -- Status Information
        isunreadbyowner as is_unread_by_owner,
        
        -- Derived Fields
        case 
            when isconverted then 'Converted'
            when upper(status) like '%QUALIFIED%' then 'Qualified'
            when upper(status) like '%OPEN%' then 'Open'
            when upper(status) like '%REJECTED%' or upper(status) like '%UNQUALIFIED%' then 'Rejected'
            else 'Other'
        end as lead_stage,
        
        case 
            when upper(leadsource) like '%WEB%' or upper(leadsource) like '%ONLINE%' then 'Digital'
            when upper(leadsource) like '%REFERRAL%' then 'Referral'
            when upper(leadsource) like '%COLD%' or upper(leadsource) like '%OUTBOUND%' then 'Outbound'
            when upper(leadsource) like '%TRADE%' or upper(leadsource) like '%EVENT%' then 'Events'
            else 'Other'
        end as lead_source_category,
        
        case 
            when upper(rating) like '%HOT%' then 'Hot'
            when upper(rating) like '%WARM%' then 'Warm'
            when upper(rating) like '%COLD%' then 'Cold'
            else 'Unknown'
        end as lead_rating_category,
        
        -- Timestamps
        createddate as created_at,
        createdbyid as created_by_id,
        lastmodifieddate as last_modified_at,
        lastmodifiedbyid as last_modified_by_id,
        systemmodstamp as system_modified_at,
        
        current_timestamp as dbt_updated_at
        
    from leads
)

select * from final 