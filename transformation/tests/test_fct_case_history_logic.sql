-- Test to validate business logic for fct_case_history
-- This test ensures that the derived fields make logical sense

with validation as (
    select 
        case_history_key,
        case_key,
        case_status,
        event_type,
        closure_event_count,
        escalation_event_count,
        creation_event_count,
        progress_event_count,
        days_since_previous_update,
        hours_since_previous_update,
        has_last_modified_date,
        has_previous_update,
        has_valid_time_sequence,
        last_modified_at,
        previous_update_at
        
    from {{ ref('fct_case_history') }}
),

test_results as (
    select 
        case_history_key,
        
        -- Test 1: Closure events should only be 1 when status is Closed or Resolved
        case 
            when case_status in ('Closed', 'Resolved') and closure_event_count != 1 then false
            when case_status not in ('Closed', 'Resolved') and closure_event_count != 0 then false
            else true
        end as closure_logic_valid,
        
        -- Test 2: Escalation events should only be 1 when status is Escalated
        case 
            when case_status = 'Escalated' and escalation_event_count != 1 then false
            when case_status != 'Escalated' and escalation_event_count != 0 then false
            else true
        end as escalation_logic_valid,
        
        -- Test 3: Creation events should only be 1 when status is New
        case 
            when case_status = 'New' and creation_event_count != 1 then false
            when case_status != 'New' and creation_event_count != 0 then false
            else true
        end as creation_logic_valid,
        
        -- Test 4: Progress events should only be 1 when status is Working or In Progress
        case 
            when case_status in ('Working', 'In Progress') and progress_event_count != 1 then false
            when case_status not in ('Working', 'In Progress') and progress_event_count != 0 then false
            else true
        end as progress_logic_valid,
        
        -- Test 5: Time calculations should be positive when valid
        case 
            when has_valid_time_sequence = true and days_since_previous_update < 0 then false
            when has_valid_time_sequence = true and hours_since_previous_update < 0 then false
            else true
        end as time_logic_valid,
        
        -- Test 6: Event type should match status
        case 
            when case_status = 'Closed' and event_type != 'Case Closed' then false
            when case_status = 'Resolved' and event_type != 'Case Resolved' then false
            when case_status in ('Working', 'In Progress') and event_type != 'Case In Progress' then false
            when case_status = 'New' and event_type != 'Case Created' then false
            when case_status = 'Open' and event_type != 'Case Opened' then false
            when case_status = 'Escalated' and event_type != 'Case Escalated' then false
            when case_status = 'Pending' and event_type != 'Case Pending' then false
            else true
        end as event_type_logic_valid,
        
        -- Test 7: Date flags should be consistent
        case 
            when last_modified_at is not null and has_last_modified_date != true then false
            when last_modified_at is null and has_last_modified_date != false then false
            when previous_update_at is not null and has_previous_update != true then false
            when previous_update_at is null and has_previous_update != false then false
            else true
        end as date_flags_valid
        
    from validation
)

select 
    case_history_key,
    closure_logic_valid,
    escalation_logic_valid,
    creation_logic_valid,
    progress_logic_valid,
    time_logic_valid,
    event_type_logic_valid,
    date_flags_valid
    
from test_results
where not (
    closure_logic_valid 
    and escalation_logic_valid 
    and creation_logic_valid 
    and progress_logic_valid 
    and time_logic_valid 
    and event_type_logic_valid 
    and date_flags_valid
) 