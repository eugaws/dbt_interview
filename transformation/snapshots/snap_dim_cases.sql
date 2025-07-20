{% snapshot snap_dim_cases %}
{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='case_key',
        check_cols=[
            'case_number', 'subject', 'description', 'case_type', 'case_status', 'priority', 'reason',
            'account_id', 'contact_id', 'owner_id', 'created_by_id', 'last_modified_by_id',
            'is_closed', 'is_escalated', 'sla_violation', 'sla_status', 'priority_level', 'case_stage',
            'escalation_level', 'channel_clean', 'created_at', 'last_modified_at', 'system_modified_at', 'closed_date'
        ]
    )
}}

select
    case_key,
    case_number,
    subject,
    description,
    case_type,
    case_status,
    priority,
    reason,
    account_id,
    contact_id,
    owner_id,
    created_by_id,
    last_modified_by_id,
    is_closed,
    is_escalated,
    sla_violation,
    sla_status,
    priority_level,
    case_stage,
    escalation_level,
    channel_clean,
    created_at,
    last_modified_at,
    system_modified_at,
    closed_date
from {{ ref('dim_cases') }}

{% endsnapshot %} 