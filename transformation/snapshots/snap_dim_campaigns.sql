{% snapshot snap_dim_campaigns %}
{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='campaign_key',
        check_cols=[
            'campaign_name', 'campaign_type', 'campaign_status', 'parent_campaign_id', 'owner_id',
            'start_date', 'end_date', 'created_at', 'last_modified_at', 'is_active'
        ]
    )
}}

select
    campaign_key,
    campaign_name,
    campaign_type,
    campaign_status,
    parent_campaign_id,
    owner_id,
    start_date,
    end_date,
    created_at,
    last_modified_at,
    is_active
from {{ ref('dim_campaigns') }}

{% endsnapshot %} 