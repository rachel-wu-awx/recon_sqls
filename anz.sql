-- Payout

select 
* from 
(SELECT 
re.DATA ->> 'reconciliationId' recon_id, 
re."data" #>> '{reconEntity, entityId}' entity_id, 
re."data" #>> '{reconHandSide,source}' side, 
re."data" ->> 'reconTxType' transaction_type, 
re."data" ->> 'amount' amount, 
re."data" ->> 'currency' currency,
rma."data" #>> '{rawData, awx_bank_account_number}' rails_bank_account,
rma."data" #>> '{rawData, value_date}' rails_value_date,
re."data" ->> 'description' description,
(regexp_split_to_array(re."data" ->> 'description', '\s+'))[2]  rails_client_ref
from recon_entry re left join recon_msc_arch rma on re.id = rma.origin_id 
where re."data" ->> 'originalControlId' = '70eed0d5-ef1c-401e-a131-0b683150112d' 
and  re."data" ->> 'reconTxType' = 'PAYMENT'
and  re."data" #>> '{reconHandSide,source}'  = 'RAIL') channel

right OUTER join
(SELECT 
re.DATA ->> 'reconciliationId' recon_id, 
re."data" #>> '{reconEntity, entityId}' entity_id, 
re."data" #>> '{reconHandSide,source}' side, 
re."data" ->> 'reconTxType' transaction_type, 
re."data" ->> 'amount' amount, 
re."data" ->> 'currency' currency,
rma."data" -> 0 #>> '{accountingJournalEntry, accountingJournal, channelAccountInfo,bankAccountNumber}' ledger_bank_account,
rma."data" -> 0 #>> '{entityAccountingDate}' ledger_posting_date,
re."data" ->> 'description' description,
rma."data" -> 0 #>> '{accountingJournalEntry, downstreamShortRef}' ledger_client_ref
from recon_entry re left join recon_msc_arch rma on re.id = rma.origin_id 
where re."data" ->> 'originalControlId' = '70eed0d5-ef1c-401e-a131-0b683150112d' 
and  re."data" ->> 'reconTxType' = 'PAYMENT') ledger

on 
((ledger.ledger_bank_account = channel.rails_bank_account 
and ledger.side != channel.side
and ledger.side = 'ACCOUNTING'
and channel.side  = 'RAIL'
and ledger.ledger_client_ref = channel.rails_client_ref)

or


(ledger.ledger_bank_account = channel.rails_bank_account 
and ledger.side != channel.side 
and ledger.currency = channel.currency
and ledger.amount = channel.amount)

)

--- Payment bounceback
with ledger as (

SELECT 
re.DATA ->> 'reconciliationId' recon_id, 
re."data" #>> '{reconEntity, entityId}' entity_id, 
re."data" #>> '{reconHandSide,source}' side, 
re."data" ->> 'reconTxType' transaction_type, 
re."data" ->> 'amount' amount, 
re."data" ->> 'currency' currency,
rma."data" #>> '{rawData, awx_bank_account_number}'bank_account,
rma."data" #>> '{rawData, value_date}' value_date,
re."data" ->> 'description' description
from recon_entry re left join recon_msc_arch rma on re.id = rma.origin_id 
where re."data" ->> 'originalControlId' = '70eed0d5-ef1c-401e-a131-0b683150112d' 


and re."data" ->> 'reconTxType' ='PAYMENT_BOUNCEDBACK'

and  re."data" #>> '{reconHandSide,source}'  = 'ACCOUNTING'

), 
channel as (
SELECT 
re.DATA ->> 'reconciliationId' recon_id, 
re."data" #>> '{reconEntity, entityId}' entity_id, 
re."data" #>> '{reconHandSide,source}' side, 
re."data" ->> 'reconTxType' transaction_type, 
re."data" ->> 'amount' amount, 
re."data" ->> 'currency' currency,
rma."data" #>> '{rawData, awx_bank_account_number}'bank_account,
rma."data" #>> '{rawData, value_date}' value_date,
re."data" ->> 'description' description
from recon_entry re left join recon_msc_arch rma on re.id = rma.origin_id 
where re."data" ->> 'originalControlId' = '70eed0d5-ef1c-401e-a131-0b683150112d' 


and re."data" ->> 'reconTxType' ='PAYMENT_BOUNCEDBACK'

and  re."data" #>> '{reconHandSide,source}'  = 'RAIL'


)


select 
case 
when ledger.recon_id is null then 'less'
when channel.recon_id is null then 'more'
when ledger.recon_id is not null and channel.recon_id is not null and ledger.value_date != channel.value_date then 'date_diff'
end as recon_result,
*


from channel full outer join ledger on channel.bank_account = ledger.bank_account
and round(cast (channel.amount  as numeric), 2) = round(cast (ledger.amount  as numeric), 2)
and channel.currency = ledger.currency
