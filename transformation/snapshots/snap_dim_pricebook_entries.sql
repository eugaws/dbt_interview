{% snapshot snap_dim_pricebook_entries %}
{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='pricebook_entry_key',
        check_cols=[
            'pricebook_key', 'product_key', 'created_by_key', 'last_modified_by_key',
            'unitprice', 'isactive', 'usestandardprice', 'created_at', 'last_modified_at', 'system_modified_at', 'dbt_updated_at'
        ]
    )
}}

select
    pricebook_entry_key,
    pricebook_key,
    product_key,
    created_by_key,
    last_modified_by_key,
    unitprice,
    isactive,
    usestandardprice,
    created_at,
    last_modified_at,
    system_modified_at,
    dbt_updated_at
from {{ ref('dim_pricebook_entries') }}

{% endsnapshot %} 