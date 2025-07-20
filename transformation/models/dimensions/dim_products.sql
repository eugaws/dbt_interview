{{
  config(
    materialized='table'
  )
}}

with products as (
    select * from {{ ref('stg_salesforce__product_2') }}
    where not isdeleted
),

final as (
    select
        -- Primary Key
        product_id as product_key,

        -- Product Information
        name as product_name,
        productcode as product_code,
        description,
        family,

        -- Status Information
        isactive as is_active,

        -- Timestamps
        createddate as created_at,
        createdbyid as created_by_id,
        lastmodifieddate as last_modified_at,
        lastmodifiedbyid as last_modified_by_id,
        systemmodstamp as system_modified_at,

        current_timestamp as dbt_updated_at

    from products
)

select * from final
