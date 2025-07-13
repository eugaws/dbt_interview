-- Data quality tests for fct_case_history
-- This test validates data integrity, consistency, and business rules

with case_history as (
    select * from {{ ref('fct_case_history') }}
),

data_quality_checks as (
    select 
        -- Test 1: Check for duplicate case_history_key
        count(*) as total_records,
        count(distinct case_history_key) as unique_keys,
        
        -- Test 2: Check for null foreign keys that should be required
        count(case when case_key is null then 1 end) as null_case_keys,
        count(case when last_modified_at is null then 1 end) as null_last_modified_at,
        
        -- Test 3: Check for missing date keys when dates are available
        count(case when last_modified_at is not null and last_modified_date_key is null then 1 end) as missing_last_modified_date_keys,
        count(case when previous_update_at is not null and previous_update_date_key is null then 1 end) as missing_previous_update_date_keys,
        
        -- Test 4: Check for inconsistent event counts
        count(case when closure_event_count + escalation_event_count + creation_event_count + progress_event_count > 1 then 1 end) as multiple_event_types,
        
        -- Test 5: Check for invalid status values
        count(case when case_status is null then 1 end) as null_status,
        
        -- Test 6: Check for future dates (data quality issue) - Fixed timestamp comparison
        count(case when last_modified_at > cast(current_timestamp as timestamp) then 1 end) as future_last_modified_dates,
        count(case when previous_update_at is not null and previous_update_at > cast(current_timestamp as timestamp) then 1 end) as future_previous_update_dates,
        
        -- Test 7: Check for unreasonable time differences (only when valid time sequence exists)
        count(case when has_valid_time_sequence = true and days_since_previous_update > 365 then 1 end) as very_old_updates,
        count(case when has_valid_time_sequence = true and hours_since_previous_update > 8760 then 1 end) as very_old_hourly_updates
        
    from case_history
),

validation_results as (
    select 
        total_records,
        unique_keys,
        null_case_keys,
        null_last_modified_at,
        missing_last_modified_date_keys,
        missing_previous_update_date_keys,
        multiple_event_types,
        null_status,
        future_last_modified_dates,
        future_previous_update_dates,
        very_old_updates,
        very_old_hourly_updates,
        
        -- Calculate quality metrics
        case when total_records > 0 then (unique_keys::float / total_records) else 0 end as uniqueness_ratio,
        case when total_records > 0 then (null_case_keys::float / total_records) else 0 end as null_case_key_ratio
        
    from data_quality_checks
)

select 
    'Data Quality Check' as test_name,
    total_records,
    unique_keys,
    null_case_keys,
    null_last_modified_at,
    missing_last_modified_date_keys,
    missing_previous_update_date_keys,
    multiple_event_types,
    null_status,
    future_last_modified_dates,
    future_previous_update_dates,
    very_old_updates,
    very_old_hourly_updates,
    uniqueness_ratio,
    null_case_key_ratio
    
from validation_results
where 
    -- Only return results if there are actual data quality issues
    null_case_keys > 0
    or null_last_modified_at > 0
    or missing_last_modified_date_keys > 0
    or missing_previous_update_date_keys > 0
    or multiple_event_types > 0
    or null_status > 0
    or future_last_modified_dates > 0
    or future_previous_update_dates > 0
    or very_old_updates > 0
    or very_old_hourly_updates > 0
    or uniqueness_ratio < 1.0

-- This query will return results if there are data quality issues
-- A clean result set means the data quality is good 