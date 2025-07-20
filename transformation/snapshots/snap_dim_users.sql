{% snapshot snap_dim_users %}
{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='user_key',
        check_cols=[
            'username', 'first_name', 'last_name', 'full_name', 'email', 'phone', 'mobile_phone',
            'user_type', 'user_subtype', 'is_active', 'last_login_at', 'manager_id', 'contact_id', 'account_id',
            'created_at', 'created_by_id', 'last_modified_at', 'last_modified_by_id', 'user_status', 'activity_status',
            'user_type_category', 'dbt_updated_at'
        ]
    )
}}

select
    user_key,
    username,
    first_name,
    last_name,
    full_name,
    email,
    phone,
    mobile_phone,
    user_type,
    user_subtype,
    is_active,
    last_login_at,
    manager_id,
    contact_id,
    account_id,
    created_at,
    created_by_id,
    last_modified_at,
    last_modified_by_id,
    user_status,
    activity_status,
    user_type_category,
    dbt_updated_at
from {{ ref('dim_users') }}

{% endsnapshot %} 