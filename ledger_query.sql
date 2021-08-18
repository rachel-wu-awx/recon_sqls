--- subject_number is the sub ledger account id
select * 
from general_ledger_entry
where settlement_date > '2021-08-07'
and settlement_date < '2021-08-10'
and accounting_journal_entry->>'entityAccountingDate' = '2021-08-09'
and subject_number in ('10101','10102','10103')
and accounting_journal_entry->'accountingJournal'->>'channelId' = 'CommunityFederalSavingsBank'
