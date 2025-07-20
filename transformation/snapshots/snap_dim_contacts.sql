{% snapshot snap_dim_contacts %}
{{
    config(
        target_schema='snapshots',
        strategy='check',
        unique_key='contact_key',
        check_cols=[
            'first_name', 'last_name', 'full_name', 'email', 'phone', 'mobile_phone', 'title', 'department',
            'account_id', 'mailing_street', 'mailing_city', 'mailing_state', 'mailing_postal_code', 'mailing_country',
            'mailing_country_clean', 'lead_source', 'description', 'email_bounced_date', 'email_bounced_reason',
            'do_not_call', 'has_opted_out_of_email', 'seniority_level', 'functional_area', 'preferred_contact_method',
            'created_at', 'last_modified_at', 'system_modified_at'
        ]
    )
}}

select
    contact_key,
    first_name,
    last_name,
    full_name,
    email,
    phone,
    mobile_phone,
    title,
    department,
    account_id,
    mailing_street,
    mailing_city,
    mailing_state,
    mailing_postal_code,
    mailing_country,
    mailing_country_clean,
    lead_source,
    description,
    email_bounced_date,
    email_bounced_reason,
    do_not_call,
    has_opted_out_of_email,
    seniority_level,
    functional_area,
    preferred_contact_method,
    created_at,
    last_modified_at,
    system_modified_at
from {{ ref('dim_contacts') }}

{% endsnapshot %} 