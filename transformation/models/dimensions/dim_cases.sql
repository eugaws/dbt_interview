{{
  config(
    materialized='table'
  )
}}

with cases as (
    select * from {{ ref('stg_salesforce__case') }}
    where not isdeleted
),

final as (
    select
        -- Primary Key
        case_id as case_key,

        -- Case Information
        casenumber as case_number,
        subject,
        description,
        type as case_type,
        status as case_status,
        priority,
        reason,

        -- Relationships
        accountid as account_id,
        contactid as contact_id,
        ownerid as owner_id,
        createdbyid as created_by_id,
        lastmodifiedbyid as last_modified_by_id,

        -- Status Information
        isclosed as is_closed,
        isescalated as is_escalated,

        -- SLA Information
        slaviolation__c as sla_violation,
        createddate as created_at,

        -- Priority Classification
        lastmodifieddate as last_modified_at,

        -- Case Stage
        systemmodstamp as system_modified_at,

        -- Escalation Level
        closeddate as closed_date,

        -- Channel Clean
        case
            when slaviolation__c = 'Yes' then 'Violated'
            when slaviolation__c = 'No' then 'Met'
            else 'Unknown'
        end as sla_status,

        -- Timestamps
        case
            when upper(priority) like '%HIGH%' or upper(priority) like '%CRITICAL%' then 'High'
            when upper(priority) like '%MEDIUM%' or upper(priority) like '%NORMAL%' then 'Medium'
            when upper(priority) like '%LOW%' then 'Low'
            else 'Unknown'
        end as priority_level,
        case
            when isclosed then 'Closed'
            when upper(status) like '%OPEN%' then 'Open'
            when upper(status) like '%ACTIVE%' then 'Active'
            else 'Other'
        end as case_stage,
        case
            when isescalated and upper(priority) like '%HIGH%' then 'Critical Escalation'
            when isescalated and upper(priority) like '%MEDIUM%' then 'Medium Escalation'
            when isescalated then 'Low Priority Escalation'
            else 'No Escalation'
        end as escalation_level,
        case
            when upper(origin) like '%EMAIL%' then 'Email'
            when upper(origin) like '%PHONE%' then 'Phone'
            when upper(origin) like '%WEB%' then 'Web'
            when upper(origin) like '%PORTAL%' then 'Portal'
            else 'Other'
        end as channel_clean,

        current_timestamp as dbt_updated_at

    from cases
)

select * from final
