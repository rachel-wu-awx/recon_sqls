-- query cfsb (EOD) database
select created,* from files WHERE direction = 'INCOMING' and type = 'CSV' AND created > '2021-08-02' and name like '%ALLACHTRANS_AWX_HK%' and content like '%5032%'
select created, type, * from files WHERE  name like '%TXN%' and content like '%662.51%'  and name like '%TXNDDA%'


-- query cfsb intraday database
select * from awx_cfsb_transaction_record where transaction_date_time > '2021-08-01' and transaction_amount = 469.69
