{{
  config(
    materialized='table'
  )
}}

with users as (
    select * from {{ ref('stg_salesforce__user') }}
),

final as (
    select
        -- Primary Key
        user_id as user_key,

        -- User Information
        username,
        firstname as first_name,
        lastname as last_name,
        email,
        phone,
        mobilephone as mobile_phone,
        usertype as user_type,

        -- System Information
        usersubtype as user_subtype,
        isactive as is_active,

        -- Status & Activity
        lastlogindate as last_login_at,
        managerid as manager_id,

        -- Relationships
        contactid as contact_id,
        accountid as account_id,
        createddate as created_at,

        -- Audit Fields
        createdbyid as created_by_id,
        lastmodifieddate as last_modified_at,
        lastmodifiedbyid as last_modified_by_id,
        concat(firstname, ' ', lastname) as full_name,

        -- Derived Fields
        case
            when isactive then 'Active'
            else 'Inactive'
        end as user_status,

        case
            when usertype in ('AutomatedProcess', 'CloudIntegrationUser', 'SfdcAdmin') then 'System User'
            when lastlogindate >= current_date - interval '30 days' then 'Recently Active'
            when lastlogindate >= current_date - interval '90 days' then 'Active'
            when lastlogindate >= current_date - interval '180 days' then 'Inactive'
            when lastlogindate is null then 'Never Logged In'
            else 'Long Inactive'
        end as activity_status,

        case
            when usertype in ('AutomatedProcess', 'CloudIntegrationUser', 'SfdcAdmin') then 'System'
            when usertype = 'CsnOnly' then 'Customer Support'
            when usertype = 'Standard' then 'Standard'
            else 'Other'
        end as user_type_category,

        current_timestamp as dbt_updated_at

    from users
)

select * from final
