{% snapshot snap_dim_user_roles %}
{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='user_role_key',
        check_cols=[
            'role_name', 'parent_role_id', 'rollup_description', 'portal_type', 'portal_role',
            'opportunity_access_for_account_owner', 'case_access_for_account_owner', 'contact_access_for_account_owner',
            'forecast_user_id', 'may_forecast_manager_share', 'portal_account_id', 'portal_account_owner_id',
            'role_level', 'role_category', 'user_type', 'management_level', 'functional_area', 'scope_type', 'has_parent_role',
            'last_modified_at', 'last_modified_by_id', 'dbt_updated_at'
        ]
    )
}}

select
    user_role_key,
    role_name,
    parent_role_id,
    rollup_description,
    portal_type,
    portal_role,
    opportunity_access_for_account_owner,
    case_access_for_account_owner,
    contact_access_for_account_owner,
    forecast_user_id,
    may_forecast_manager_share,
    portal_account_id,
    portal_account_owner_id,
    role_level,
    role_category,
    user_type,
    management_level,
    functional_area,
    scope_type,
    has_parent_role,
    last_modified_at,
    last_modified_by_id,
    dbt_updated_at
from {{ ref('dim_user_roles') }}

{% endsnapshot %} 