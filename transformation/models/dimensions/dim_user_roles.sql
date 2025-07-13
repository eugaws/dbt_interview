{{
  config(
    materialized='table',
    unique_key='user_role_key'
  )
}}

with user_roles as (
    select * from {{ ref('stg_salesforce__user_role') }}
),

final as (
    select
        -- Primary Key
        user_role_id as user_role_key,
        
        -- Role Information
        name as role_name,
        parentroleid as parent_role_id,
        rollupdescription as rollup_description,
        portaltype as portal_type,
        portalrole as portal_role,
        
        -- Access Controls
        opportunityaccessforaccountowner as opportunity_access_for_account_owner,
        caseaccessforaccountowner as case_access_for_account_owner,
        contactaccessforaccountowner as contact_access_for_account_owner,
        
        -- Forecast Settings
        forecastuserid as forecast_user_id,
        mayforecastmanagershare as may_forecast_manager_share,
        
        -- Portal Information
        portalaccountid as portal_account_id,
        portalaccountownerid as portal_account_owner_id,
        
        -- Derived Fields - Fixed based on actual data patterns
        case 
            when parentroleid is null or parentroleid = '000000000000000AAA' then 'Top Level'
            else 'Subordinate'
        end as role_level,
        
        case 
            when upper(name) like '%CEO%' or upper(name) like '%PRESIDENT%' then 'C-Level'
            when upper(name) like '%VP%' or upper(name) like '%VICE%' then 'VP'
            when upper(name) like '%DIRECTOR%' then 'Director'
            when upper(name) like '%MANAGER%' then 'Manager'
            when upper(name) like '%SALES%' then 'Sales'
            when upper(name) like '%MARKETING%' then 'Marketing'
            when upper(name) like '%SUPPORT%' then 'Support'
            else 'Other'
        end as role_category,
        
        case 
            when portaltype is not null and portaltype != 'None' then 'Portal User'
            else 'Internal User'
        end as user_type,
        
        -- Additional Derived Fields for Better Analytics
        case 
            when upper(name) like '%CEO%' or upper(name) like '%CFO%' or upper(name) like '%COO%' then 'Executive'
            when upper(name) like '%SVP%' or upper(name) like '%VP%' then 'Senior Management'
            when upper(name) like '%DIRECTOR%' then 'Middle Management'
            when upper(name) like '%TEAM%' then 'Team Level'
            else 'Individual Contributor'
        end as management_level,
        
        case 
            when upper(name) like '%SALES%' then 'Sales'
            when upper(name) like '%MARKETING%' then 'Marketing'
            when upper(name) like '%SUPPORT%' or upper(name) like '%CUSTOMER%' then 'Customer Service'
            when upper(name) like '%HUMAN%' or upper(name) like '%HR%' then 'Human Resources'
            when upper(name) like '%INSTALLATION%' or upper(name) like '%REPAIR%' then 'Operations'
            else 'Other'
        end as functional_area,
        
        case 
            when upper(name) like '%NORTH%' or upper(name) like '%EASTERN%' or upper(name) like '%WESTERN%' then 'Regional'
            when upper(name) like '%INTERNATIONAL%' then 'International'
            when upper(name) like '%CHANNEL%' then 'Channel'
            else 'General'
        end as scope_type,
        
        case 
            when parentroleid is not null and parentroleid != '000000000000000AAA' then true
            else false
        end as has_parent_role,
        
        -- Audit Fields
        lastmodifieddate as last_modified_at,
        lastmodifiedbyid as last_modified_by_id,
        
        current_timestamp as dbt_updated_at
        
    from user_roles
)

select * from final 