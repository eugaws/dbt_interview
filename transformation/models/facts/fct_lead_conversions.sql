{{
  config(
    materialized='table',
    unique_key='lead_conversion_key'
  )
}}

with lead_conversions as (
    select * from {{ ref('stg_salesforce__lead') }}
    where
        not isdeleted
        and (
        -- Primary conversion criteria
            (isconverted = true and converteddate is not null)
            -- Fallback for data quality issues: use status-based conversion detection
            or status = 'Closed - Converted'
        )
),

final as (
    select
        -- Primary Key
        lead_id as lead_key,

        -- Foreign Keys (Dimension References)
        convertedaccountid as account_key,
        convertedcontactid as contact_key,
        convertedopportunityid as opportunity_key,
        ownerid as owner_key,
        createdbyid as created_by_key,
        cast(createddate as timestamp) as lead_created_date,

        -- Date Foreign Keys (with fallback logic for data quality issues)
        1 as conversion_count,
        lead_id || '_conversion' as lead_conversion_key,

        -- Conversion Event Information (with fallback logic)
        case
            when converteddate is not null then date(cast(converteddate as timestamp))
            when status = 'Closed - Converted' then date(cast(lastmodifieddate as timestamp))
            else date(cast(createddate as timestamp))
        end as converted_date_key,
        date(cast(createddate as timestamp)) as lead_created_date_key,

        -- Key Metrics (Measures)
        case
            when converteddate is not null then cast(converteddate as timestamp)
            when status = 'Closed - Converted' then cast(lastmodifieddate as timestamp)
            else cast(createddate as timestamp)
        end as conversion_date,
        case
            when
                converteddate is not null
                then datediff('day', cast(createddate as timestamp), cast(converteddate as timestamp))
            when
                status = 'Closed - Converted'
                then datediff('day', cast(createddate as timestamp), cast(lastmodifieddate as timestamp))
            else 0
        end as days_to_conversion,
        coalesce(cast(annualrevenue as decimal(15, 2)), 0.0) as converted_lead_revenue,

        -- Conversion Counts (for aggregation)
        coalesce(cast(numberofemployees as decimal(10, 0)), 0.0) as converted_lead_employees,

        -- One-hot encoding for conversion_velocity
        case when (
            (
                converteddate is not null
                and datediff('day', cast(createddate as timestamp), cast(converteddate as timestamp)) <= 7
            )
            or (
                status = 'Closed - Converted'
                and datediff('day', cast(createddate as timestamp), cast(lastmodifieddate as timestamp)) <= 7
            )
        ) then 1 else 0 end as conversion_velocity_very_fast_flg,
        case when (
            (
                converteddate is not null
                and datediff('day', cast(createddate as timestamp), cast(converteddate as timestamp)) > 7
                and datediff('day', cast(createddate as timestamp), cast(converteddate as timestamp)) <= 30
            )
            or (
                status = 'Closed - Converted'
                and datediff('day', cast(createddate as timestamp), cast(lastmodifieddate as timestamp)) > 7
                and datediff('day', cast(createddate as timestamp), cast(lastmodifieddate as timestamp)) <= 30
            )
        ) then 1 else 0 end as conversion_velocity_fast_flg,
        case when (
            (
                converteddate is not null
                and datediff('day', cast(createddate as timestamp), cast(converteddate as timestamp)) > 30
                and datediff('day', cast(createddate as timestamp), cast(converteddate as timestamp)) <= 90
            )
            or (
                status = 'Closed - Converted'
                and datediff('day', cast(createddate as timestamp), cast(lastmodifieddate as timestamp)) > 30
                and datediff('day', cast(createddate as timestamp), cast(lastmodifieddate as timestamp)) <= 90
            )
        ) then 1 else 0 end as conversion_velocity_medium_flg,
        case when (
            (
                converteddate is not null
                and datediff('day', cast(createddate as timestamp), cast(converteddate as timestamp)) > 90
                and datediff('day', cast(createddate as timestamp), cast(converteddate as timestamp)) <= 180
            )
            or (
                status = 'Closed - Converted'
                and datediff('day', cast(createddate as timestamp), cast(lastmodifieddate as timestamp)) > 90
                and datediff('day', cast(createddate as timestamp), cast(lastmodifieddate as timestamp)) <= 180
            )
        ) then 1 else 0 end as conversion_velocity_slow_flg,
        case when (
            (
                converteddate is not null
                and datediff('day', cast(createddate as timestamp), cast(converteddate as timestamp)) > 180
            )
            or (
                status = 'Closed - Converted'
                and datediff('day', cast(createddate as timestamp), cast(lastmodifieddate as timestamp)) > 180
            )
        ) then 1 else 0 end as conversion_velocity_very_slow_flg,
        case when (
            (converteddate is null and status != 'Closed - Converted')
        ) then 1 else 0 end as conversion_velocity_unknown_flg,

        -- Conversion Success Flags
        case when convertedopportunityid is not null then 1 else 0 end as created_opportunity_flag,
        case when convertedaccountid is not null then 1 else 0 end as created_account_flag,
        case when convertedcontactid is not null then 1 else 0 end as created_contact_flag,

        -- Data Quality Indicators
        case when isconverted = true then 1 else 0 end as is_officially_converted,
        case when converteddate is not null then 1 else 0 end as has_conversion_date,
        case when status = 'Closed - Converted' then 1 else 0 end as status_indicates_conversion,

        -- Conversion Detection Method (one-hot encoding)
        case when isconverted = true and converteddate is not null then 1 else 0 end
            as conversion_detection_method_official_flg,
        case when status = 'Closed - Converted' then 1 else 0 end as conversion_detection_method_status_fallback_flg,
        case
            when not (isconverted = true and converteddate is not null) and status != 'Closed - Converted' then 1 else 0
        end as conversion_detection_method_unknown_flg,

        current_timestamp as dbt_updated_at

    from lead_conversions
)

select * from final
