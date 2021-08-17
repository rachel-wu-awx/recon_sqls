
/*query fund recon*/
SELECT 
re.DATA ->> 'reconciliationId' recon_id, 
re."data" #>> '{reconEntity, entityId}' entity_id, 
re."data" #>> '{reconHandSide,source}' side, re."data" ->> 'reconTxType' transaction_type, 
re."data" ->> 'amount' amount, re."data" ->> 'currency' currency,
re."data" ->> 'description' description,
re.id entry_id, re.create_time , re.last_update , 
re."data" ->> 'type' entry_type, re."data" ->> 'scope' entry_scope,
re."data" ->> 'businessType' business_type,
re."data" #>> '{bankAccountInfo, purpose}' account_purpose,
re."data" #>> '{bankAccountInfo, bankAccount, accountNumber}' bank_account_no,
re."data" #>> '{bankAccountInfo, bankAccount, accountCurrency}' bank_account_ccy,
re."data" #>> '{bankAccountInfo, bankAccount, id}' bank_account_id,
re."data" ->> 'settlementTime' settlement_time,
re."data" ->> 'orderId' order_id, re."data" ->> 'transactionId' transaction_id, re.DATA ->> 'uniqueId' unique_id,
re."data" ->> 'reconEntryType' entry_type,
re."data" -> 'matchedEntries' matched_entries,
re."data" ->> 'producedError' error_id,
re."data" ->> 'originalControlId' control_id,
re."data" recon_entry_data,
rma."data" raw_data
from recon_entry re left join recon_msc_arch rma on re.id = rma.origin_id 
where re."data" ->> 'originalControlId' = '';


/*query result*/

SELECT 
ree.create_time , ree.last_update ,
ree.id error_id,
ree."data" ->> 'type' entry_type, ree."data" ->> 'scope' entry_scope,
ree."data" ->> 'businessType' business_type,
ree."data" ->> 'settlementTime' settlement_time,
ree."data" ->> 'status' error_status,
ree."data" ->> 'diffType' diff_type, 
ree."data" ->> 'diffSubType' diff_sub_type,
ree."data" #>> '{bankAccountInfo, bankAccount, accountCurrency}' bank_account_ccy,
ree."data" #>> '{bankAccountInfo, bankAccount, id}' bank_account_id,
ree."data" ->> 'fromEntryId' from_entry_id,
ree."data" #>> '{reconEntity, entityId}' entity_id, 
ree.DATA ->> 'reconciliationId' recon_id,
ree."data" ->> 'originalReconDate' original_recon_date,
ree."data" ->> 'reconTxType' transaction_type,
ree."data" ->> 'currency' currency,
ree."data" #>> '{bankAccountInfo, purpose}' account_purpose,
ree."data" #>> '{reconHandSide,source}' side,
ree."data" ->> 'amount' amount, 
ree."data" #>> '{bankAccountInfo, bankAccount, accountNumber}' bank_account_no,
ree."data" #>> '{clientBankAccount,accountNumber}' clientBankAccount,
ree."data" ->> 'description' description,
rma."data" raw_data
from recon_error_entry ree LEFT JOIN recon_msc_arch rma ON ree."data" ->> 'fromEntryId' = rma.origin_id::text where ree."data" ->> 'originalControlId' = 'eab492ae-cf98-43eb-9893-43d604ca73b9'
AND ree."data" ->> 'status' = 'PENDING'
ORDER BY ree."data" -> 'amount', ree."data" ->> 'currency', ree."data" #>> '{reconHandSide,source}';


/*query ledger*/

select * from general_ledger_entry t where t.subject_number in ('10101','10102') and settlement_date >= '2021-06-30 16:00:00' and settlement_date < '2021-07-01 16:00:00'
and account_info->>'mhId' in ('AirwallexAU') ;





