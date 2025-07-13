{{
  config(
    materialized='table'
  )
}}

with pricebook_entries as (
    select * from {{ ref('stg_salesforce__pricebook_entry') }}
    where not isdeleted and not isarchived
),

final as (
    select
        -- Primary Key
        pricebook_entry_id as pricebook_entry_key,

        -- Foreign Keys
        pricebook2id as pricebook_key,
        product2id as product_key,
        createdbyid as created_by_key,
        lastmodifiedbyid as last_modified_by_key,

        -- Attributes
        unitprice,
        isactive,
        usestandardprice,

        -- Timestamps
        createddate as created_at,
        lastmodifieddate as last_modified_at,
        systemmodstamp as system_modified_at,

        current_timestamp as dbt_updated_at
    from pricebook_entries
)

select * from final 