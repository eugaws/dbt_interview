{{
  config(
    materialized='table'
  )
}}

with contacts as (
    select * from {{ ref('stg_salesforce__contact') }}
    where not isdeleted
),

final as (
    select
        -- Primary Key
        contact_id as contact_key,

        -- Contact Information
        firstname as first_name,
        lastname as last_name,
        email,
        phone,
        mobilephone as mobile_phone,
        title,
        department,
        accountid as account_id,

        -- Account Relationship
        mailingstreet as mailing_street,

        -- Address Information
        mailingcity as mailing_city,
        mailingstate as mailing_state,
        mailingpostalcode as mailing_postal_code,
        mailingcountry as mailing_country,
        leadsource as lead_source,
        description,

        -- Lead Information
        emailbounceddate as email_bounced_date,
        emailbouncedreason as email_bounced_reason,

        -- Status Information
        donotcall as do_not_call,
        hasoptedoutofemail as has_opted_out_of_email,
        createddate as created_at,
        lastmodifieddate as last_modified_at,

        -- Derived Fields
        systemmodstamp as system_modified_at,

        concat(firstname, ' ', lastname) as full_name,

        case
            when mailingcountry is null then 'Unknown'
            when upper(mailingcountry) in ('USA', 'US', 'UNITED STATES') then 'United States'
            when upper(mailingcountry) in ('FRANCE', 'FR') then 'France'
            else upper(substr(mailingcountry, 1, 1)) || lower(substr(mailingcountry, 2))
        end as mailing_country_clean,

        -- Timestamps
        case
            when
                upper(title) like '%CEO%' or upper(title) like '%CHIEF%' or upper(title) like '%PRESIDENT%'
                then 'C-Level'
            when upper(title) like '%VP%' or upper(title) like '%VICE PRESIDENT%' then 'VP'
            when upper(title) like '%DIRECTOR%' then 'Director'
            when upper(title) like '%MANAGER%' or upper(title) like '%MGR%' then 'Manager'
            when upper(title) like '%ANALYST%' or upper(title) like '%SPECIALIST%' then 'Analyst'
            else 'Other'
        end as seniority_level,
        case
            when upper(title) like '%SALES%' or upper(title) like '%ACCOUNT%' then 'Sales'
            when upper(title) like '%MARKETING%' then 'Marketing'
            when upper(title) like '%ENGINEER%' or upper(title) like '%DEVELOPER%' then 'Engineering'
            when upper(title) like '%FINANCE%' or upper(title) like '%ACCOUNTING%' then 'Finance'
            when upper(title) like '%HR%' or upper(title) like '%HUMAN%' then 'HR'
            when upper(title) like '%OPERATIONS%' or upper(title) like '%OPS%' then 'Operations'
            else 'Other'
        end as functional_area,
        case
            when email is not null and phone is not null then 'Email'
            when email is not null then 'Email'
            when phone is not null then 'Phone'
            when mobilephone is not null then 'Mobile'
            else 'Limited'
        end as preferred_contact_method,

        current_timestamp as dbt_updated_at

    from contacts
)

select * from final
