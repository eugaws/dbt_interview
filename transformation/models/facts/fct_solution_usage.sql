{{
  config(
    materialized='table',
    unique_key='solution_usage_key'
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

        -- Foreign Keys
        caseid as case_key,
        ownerid as owner_key,
        createdbyid as created_by_key,
        createddate as created_at,

        -- Date Keys
        lastmodifieddate as last_modified_at,
        solution_id || '_' || coalesce(cast(createddate as varchar), 'no_date') as solution_usage_key,

        -- Usage Metrics
        date(createddate) as created_date_key,

        -- Publication Flags
        date(lastmodifieddate) as last_modified_date_key,
        coalesce(timesused, 0) as times_used,
        case when ispublished = true then 1 else 0 end as is_published_flg,
        case when ispublishedinpublickb = true then 1 else 0 end as is_published_in_public_kb_flg,

        -- Timestamps
        case when isreviewed = true then 1 else 0 end as is_reviewed_flg,
        case when ishtml = true then 1 else 0 end as is_html_flg,
        current_timestamp as dbt_updated_at

    from solutions
)

select * from final
