{% snapshot snap_dim_products %}
{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='product_key',
        check_cols=[
            'product_name', 'product_code', 'description', 'family', 'is_active', 'created_at', 'created_by_id',
            'last_modified_at', 'last_modified_by_id', 'system_modified_at', 'dbt_updated_at'
        ]
    )
}}

select
    product_key,
    product_name,
    product_code,
    description,
    family,
    is_active,
    created_at,
    created_by_id,
    last_modified_at,
    last_modified_by_id,
    system_modified_at,
    dbt_updated_at
from {{ ref('dim_products') }}

{% endsnapshot %} 