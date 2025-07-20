{% snapshot snap_dim_opportunities %}
{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='opportunity_key',
        check_cols=[
            'account_key', 'contact_id', 'owner_key', 'campaign_id', 'pricebook_key', 'created_by_key', 'last_modified_by_key',
            'close_date_key', 'created_date_key', 'last_modified_date_key', 'last_stage_change_date_key', 'last_activity_date_key',
            'opportunity_name', 'description', 'opportunity_type', 'stage_name', 'stage_sort_order', 'lead_source', 'next_step',
            'amount', 'probability', 'expected_revenue', 'total_opportunity_quantity', 'is_closed', 'is_won', 'opportunity_status',
            'forecast_category', 'forecast_category_name', 'fiscal_year', 'fiscal_quarter', 'delivery_installation_status',
            'tracking_number', 'order_number', 'current_generators', 'main_competitors', 'deal_size_category', 'probability_category',
            'timeline_category', 'stage_category', 'business_type', 'lead_source_category', 'close_date', 'created_at',
            'last_modified_at', 'last_stage_change_at', 'last_activity_at', 'dbt_updated_at'
        ]
    )
}}

select
    opportunity_key,
    account_key,
    contact_id,
    owner_key,
    campaign_id,
    pricebook_key,
    created_by_key,
    last_modified_by_key,
    close_date_key,
    created_date_key,
    last_modified_date_key,
    last_stage_change_date_key,
    last_activity_date_key,
    opportunity_name,
    description,
    opportunity_type,
    stage_name,
    stage_sort_order,
    lead_source,
    next_step,
    amount,
    probability,
    expected_revenue,
    total_opportunity_quantity,
    is_closed,
    is_won,
    opportunity_status,
    forecast_category,
    forecast_category_name,
    fiscal_year,
    fiscal_quarter,
    delivery_installation_status,
    tracking_number,
    order_number,
    current_generators,
    main_competitors,
    deal_size_category,
    probability_category,
    timeline_category,
    stage_category,
    business_type,
    lead_source_category,
    close_date,
    created_at,
    last_modified_at,
    last_stage_change_at,
    last_activity_at,
    dbt_updated_at
from {{ ref('dim_opportunities') }}

{% endsnapshot %} 