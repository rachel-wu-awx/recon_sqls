select 
accountNum, 
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
item
 
from 
(select 
statements #>>'{accountInformation, accountNumber}' as accountNum,
statements #>'{accountInformation, balance, openingBalance}' as openningBalace,
statements #>'{accountInformation, balance, closingBalance}' as closingBalance,
statements #>>'{accountInformation, balance, date}' as balanceDate,
statements #>>'{accountInformation, currency}' as ccy, 
jsonb_array_elements(statements #>'{entries}') as item
from 
(
select 
jsonb_array_elements (report #> '{statements }') as statements , *


 from statement_report where entity_id = 'AirwallexAU' 
 ) as a) as b
 order by accountNum
