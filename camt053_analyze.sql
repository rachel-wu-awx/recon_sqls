
select
    accountNum,
    period,
    purpose,
    openningBalace,
    closingBalance,
    balanceDate,
    ccy,
    item #>> '{fundingAmount, amount}' as funding_amount,
item #>> '{fundingAmount, ccy}' as funding_ccy,
item #>> '{settlementAmount, amount}' as settlement_amount,
item #>> '{settlementAmount, ccy}' as settlement_ccy,
item #>> '{detail, extraProperties,NtryRef }' as NtryRef,
item #>> '{detail, description }' as description,
item #>> '{ category }' as category,
item #>> '{ valueDate }' as value_date,
item #>> '{drCrIndicator}' as credit_debit,
((replace (item #>> '{detail,extraProperties, addtlNtryInf }', '\', '') )::json) #>>'{narrative}' as bankRaw_narrative,
((replace (item #>> '{detail,extraProperties, addtlNtryInf }', '\', '') )::json) #>>'{bai}' as bankRaw_bai,
((replace (item #>> '{detail,extraProperties, addtlNtryInf }', '\', '') )::json) #>>'{trantype}' as bankRaw_trantype,

item

from
    (select
    statements #>>'{accountInformation, accountNumber}' as accountNum,
    statements #>>'{accountInformation, balance, openingBalance}' as openningBalace,
    statements #>>'{accountInformation, balance, closingBalance}' as closingBalance,
    statements #>>'{accountInformation, balance, date}' as balanceDate,
    statements #>>'{accountInformation, currency}' as ccy,
    statements #>>'{accountInformation, purpose}' as purpose,
    period,

    jsonb_array_elements(statements #>'{entries}') as item
    from
    (
    select
    jsonb_array_elements (report #> '{statements }') as statements , *


    from statement_report where entity_id = 'AirwallexAU' and period >'2021-08-17'
    ) as a) as b where item #>> '{ category }' like '%PAYMENT%'  and accountNum = '222765041' and item #>> '{fundingAmount, amount}' like '%771378.89%' ---'%11675.54%'--'%65893.5%'--'%2926.69%'
order by funding_amount
