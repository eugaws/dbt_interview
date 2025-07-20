{% snapshot snap_dim_solutions %}
{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='solution_key',
        check_cols=[
            'solution_number', 'solution_name', 'solution_note', 'times_used', 'is_published', 'is_published_in_public_kb',
            'solution_status', 'is_reviewed', 'is_html', 'case_id', 'owner_id', 'visibility_level', 'review_status',
            'usage_category', 'lifecycle_stage', 'publication_status', 'review_indicator', 'solution_type', 'created_at',
            'created_by_id', 'last_modified_at', 'last_modified_by_id', 'dbt_updated_at'
        ]
    )
}}

select
    solution_key,
    solution_number,
    solution_name,
    solution_note,
    times_used,
    is_published,
    is_published_in_public_kb,
    solution_status,
    is_reviewed,
    is_html,
    case_id,
    owner_id,
    visibility_level,
    review_status,
    usage_category,
    lifecycle_stage,
    publication_status,
    review_indicator,
    solution_type,
    created_at,
    created_by_id,
    last_modified_at,
    last_modified_by_id,
    dbt_updated_at
from {{ ref('dim_solutions') }}

{% endsnapshot %} 