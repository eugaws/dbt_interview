with source as (

    select * from {{ source('salesforce', 'opportunity_history') }}

),

renamed as (

    select
        id as opportunity_history_id,
        opportunityid,
        createdbyid,
        createddate,
        createddateforinsert,
        stagename,
        amount,
        expectedrevenue,
        closedate,
        probability,
        fromforecastcategory,
        forecastcategory,
        prevforecastupdate,
        fromopportunitystagename,
        prevopportunitystageupdate,
        validthroughdate,
        systemmodstamp,
        isdeleted,
        prevamount,
        prevclosedate

    from source

)

select * from renamed
