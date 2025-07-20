{{
  config(
    materialized='table',
    unique_key='case_history_key'
  )
}}

with case_history as (
    select * from {{ ref('stg_salesforce__case_history_2') }}
    where not isdeleted
),

final as (
    select
        -- Primary Key
        case_history_id as case_history_key,
        
        -- Foreign Keys (Dimension References)
        caseid as case_key,
        ownerid as owner_key,
        lastmodifiedbyid as last_modified_by_key,
        
        -- Date Foreign Keys (with proper null handling)
        case 
            when lastmodifieddate is not null then date(lastmodifieddate)
            else null
        end as last_modified_date_key,
        case 
            when previousupdate is not null and previousupdate != '' then date(try_cast(previousupdate as timestamp))
            else null
        end as previous_update_date_key,
        
        -- Change Detection (improved with better null handling and proper casting)
        case 
            when previousupdate is not null 
                 and previousupdate != ''
                 and lastmodifieddate is not null 
                 and try_cast(previousupdate as timestamp) is not null
                 and try_cast(previousupdate as timestamp) < lastmodifieddate then 
                datediff('day', try_cast(previousupdate as timestamp), lastmodifieddate)
            else null
        end as days_since_previous_update,
        case 
            when previousupdate is not null 
                 and previousupdate != ''
                 and lastmodifieddate is not null 
                 and try_cast(previousupdate as timestamp) is not null
                 and try_cast(previousupdate as timestamp) < lastmodifieddate then 
                datediff('hour', try_cast(previousupdate as timestamp), lastmodifieddate)
            else null
        end as hours_since_previous_update,
        
        -- Event Counts
        1 as history_event_count,
        case 
            when status in ('Closed', 'Resolved') then 1
            else 0
        end as closure_event_count,
        case 
            when status = 'Escalated' then 1
            else 0
        end as escalation_event_count,
        case 
            when status = 'New' then 1
            else 0
        end as creation_event_count,
        case 
            when status in ('Working', 'In Progress') then 1
            else 0
        end as progress_event_count,
        
        -- Status Change Classification (improved logic)
        -- (event_type removed, only one-hot encoding flags below)
        
        -- One-hot encoding for event_type
        case when (
            status = 'Closed'
        ) then 1 else 0 end as event_type_case_closed_flg,
        case when (
            status = 'Resolved'
        ) then 1 else 0 end as event_type_case_resolved_flg,
        case when (
            status in ('Working', 'In Progress')
        ) then 1 else 0 end as event_type_case_in_progress_flg,
        case when (
            status = 'New'
        ) then 1 else 0 end as event_type_case_created_flg,
        case when (
            status = 'Open'
        ) then 1 else 0 end as event_type_case_opened_flg,
        case when (
            status = 'Escalated'
        ) then 1 else 0 end as event_type_case_escalated_flg,
        case when (
            status = 'Pending'
        ) then 1 else 0 end as event_type_case_pending_flg,
        case when not (
            status = 'Closed' or status = 'Resolved' or status in ('Working', 'In Progress') or status = 'New' or status = 'Open' or status = 'Escalated' or status = 'Pending'
        ) then 1 else 0 end as event_type_status_change_flg,
        
        -- Data Quality Flags
        case 
            when lastmodifieddate is not null then true
            else false
        end as has_last_modified_date,
        case 
            when previousupdate is not null and previousupdate != '' then true
            else false
        end as has_previous_update,
        case 
            when previousupdate is not null 
                 and previousupdate != ''
                 and lastmodifieddate is not null 
                 and try_cast(previousupdate as timestamp) is not null
                 and try_cast(previousupdate as timestamp) < lastmodifieddate then true
            else false
        end as has_valid_time_sequence,
        
        -- Timestamps (with proper casting)
        lastmodifieddate as last_modified_at,
        try_cast(previousupdate as timestamp) as previous_update_at,
        current_timestamp as dbt_updated_at
        
    from case_history
)

select * from final 