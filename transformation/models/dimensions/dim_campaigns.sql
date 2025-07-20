{{
  config(
    materialized='table'
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

        -- Campaign Information
        name as campaign_name,
        type as campaign_type,
        status as campaign_status,
        description,

        -- Relationships
        parentid as parent_campaign_id,
        ownerid as owner_id,

        -- Dates
        startdate as start_date,
        enddate as end_date,
        createddate as created_at,
        createdbyid as created_by_id,
        lastmodifieddate as last_modified_at,
        lastmodifiedbyid as last_modified_by_id,
        lastactivitydate as last_activity_at,

        -- Status Information
        isactive as is_active,

        -- Derived Fields
        case
            when enddate < current_date then 'Completed'
            when startdate <= current_date and enddate >= current_date then 'Active'
            when startdate > current_date then 'Planned'
            else 'Unknown'
        end as campaign_phase,

        current_timestamp as dbt_updated_at

    from campaigns
)

select * from final
