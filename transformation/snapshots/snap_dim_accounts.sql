{% snapshot snap_dim_accounts %}
{{
    config(
      target_schema='snapshots',
      unique_key='account_key',
      strategy='check',
      check_cols=[
        'account_name',
        'account_type',
        'industry',
        'annual_revenue',
        'number_of_employees',
        'billing_country',
        'billing_country_clean',
        'shipping_country',
        'shipping_country_clean',
        'company_size_segment',
        'employee_size_segment',
        'industry_category',
        'account_scope'
      ]
    )
}}

select
    account_key,
    account_name,
    account_type,
    industry,
    annual_revenue,
    number_of_employees,
    billing_country,
    billing_country_clean,
    shipping_country,
    shipping_country_clean,
    company_size_segment,
    employee_size_segment,
    industry_category,
    account_scope,
    created_at,
    last_modified_at,
    system_modified_at,
    dbt_updated_at
from {{ ref('dim_accounts') }}

{% endsnapshot %} 