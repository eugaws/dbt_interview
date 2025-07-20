{% snapshot snap_dim_leads %}
{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='lead_key',
        check_cols=[
            'first_name', 'last_name', 'full_name', 'email', 'phone', 'mobile_phone', 'title', 'company',
            'lead_source', 'lead_status', 'rating', 'description', 'street', 'city', 'state', 'postal_code', 'country',
            'is_converted', 'converted_date', 'converted_opportunity_id', 'converted_account_id', 'converted_contact_id',
            'is_unread_by_owner', 'lead_stage', 'lead_source_category', 'lead_rating_category', 'created_at', 'created_by_id',
            'last_modified_at', 'last_modified_by_id', 'system_modified_at'
        ]
    )
}}

select
    lead_key,
    first_name,
    last_name,
    full_name,
    email,
    phone,
    mobile_phone,
    title,
    company,
    lead_source,
    lead_status,
    rating,
    description,
    street,
    city,
    state,
    postal_code,
    country,
    is_converted,
    converted_date,
    converted_opportunity_id,
    converted_account_id,
    converted_contact_id,
    is_unread_by_owner,
    lead_stage,
    lead_source_category,
    lead_rating_category,
    created_at,
    created_by_id,
    last_modified_at,
    last_modified_by_id,
    system_modified_at
from {{ ref('dim_leads') }}

{% endsnapshot %} 