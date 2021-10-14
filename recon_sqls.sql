select
    * from
    (SELECT
             re.DATA ->> 'reconciliationId' recon_id,
             re."data" #>> '{reconEntity, entityId}' entity_id,
             re."data" #>> '{reconHandSide,source}' side,
             re."data" ->> 'reconTxType' transaction_type,
             re."data" ->> 'amount' amount,
             re."data" ->> 'currency' currency,
             re."data" #>>'{bankAccountInfo,bankAccount, accountNumber}' as payer_bank_account,
             re."data" ->> 'beneficiaryAccountNumber' as payee_bank_account,
             re."data" ->> 'description' description,
             (regexp_split_to_array(re."data" ->> 'description', '\s+'))[2]  rails_client_ref
     from recon_entry re
     where --re."data" ->> 'originalControlId' = '70eed0d5-ef1c-401e-a131-0b683150112d'
             1=1
       and  re."data" ->> 'reconTxType' = 'PAYMENT'
       and  re."data" #>> '{reconHandSide,source}'  = 'RAIL') channel

        join
    (SELECT
             re.DATA ->> 'reconciliationId' recon_id,
             re."data" #>> '{reconEntity, entityId}' entity_id,
             re."data" #>> '{reconHandSide,source}' side,
             re."data" ->> 'reconTxType' transaction_type,
             re."data" ->> 'amount' amount,
             re."data" ->> 'currency' currency,
             re."data" #>>'{bankAccountInfo,bankAccount, accountNumber}' as payer_bank_account,
             re."data" ->> 'beneficiaryAccountNumber' as payee_bank_account,
             re."data" ->> 'description' description,
             (regexp_split_to_array(re."data" ->> 'description', '\s+'))[2]  ledger_client_ref
     from recon_entry re
     where --re."data" ->> 'originalControlId' = '70eed0d5-ef1c-401e-a131-0b683150112d'
             1=1
       and  re."data" #>> '{reconHandSide,source}'  = 'LEDGER'
       and  re."data" ->> 'reconTxType' = 'PAYMENT') ledger

    on
        (ledger.payer_bank_account = channel.payer_bank_account
            and ledger.payee_bank_account = channel.payee_bank_account
            and ledger.amount = channel.amount
            and ledger.currency = channel.currency

            )