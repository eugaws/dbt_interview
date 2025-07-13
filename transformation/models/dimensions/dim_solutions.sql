{{
  config(
    materialized='table',
    unique_key='solution_key'
  )
}}

with solutions as (
    select * from {{ ref('stg_salesforce__solution') }}
    where not isdeleted
),

final as (
    select
        -- Primary Key
        solution_id as solution_key,
        
        -- Solution Information
        solutionnumber as solution_number,
        solutionname as solution_name,
        solutionnote as solution_note,
        timesused as times_used,
        
        -- Status Information
        ispublished as is_published,
        ispublishedinpublickb as is_published_in_public_kb,
        status as solution_status,
        isreviewed as is_reviewed,
        ishtml as is_html,
        
        -- Relationships
        caseid as case_id,
        ownerid as owner_id,
        
        -- Derived Fields
        case 
            when ispublished and ispublishedinpublickb then 'Public'
            when ispublished and not ispublishedinpublickb then 'Internal'
            else 'Draft'
        end as visibility_level,
        
        case 
            when isreviewed and ispublished then 'Approved'
            when isreviewed and not ispublished then 'Reviewed - Not Published'
            when not isreviewed and ispublished then 'Published - Not Reviewed'
            else 'Draft'
        end as review_status,
        
        case 
            when timesused >= 100 then 'Highly Used'
            when timesused >= 50 then 'Frequently Used'
            when timesused >= 10 then 'Moderately Used'
            when timesused > 0 then 'Rarely Used'
            else 'Not Used'
        end as usage_category,
        
        case 
            when status = 'Reviewed' and ispublished then 'Active'
            when status = 'Draft' then 'In Progress'
            when status = 'Obsolete' then 'Archived'
            else 'Other'
        end as lifecycle_stage,
        
        -- Additional Derived Fields for Better Analytics
        case 
            when ispublished then 'Published'
            else 'Unpublished'
        end as publication_status,
        
        case 
            when isreviewed then 'Reviewed'
            else 'Not Reviewed'
        end as review_indicator,
        
        case 
            when case_id is not null then 'Case-Linked'
            else 'Standalone'
        end as solution_type,
        
        -- Audit Fields
        createddate as created_at,
        createdbyid as created_by_id,
        lastmodifieddate as last_modified_at,
        lastmodifiedbyid as last_modified_by_id,
        
        current_timestamp as dbt_updated_at
        
    from solutions
)

select * from final 