select created,* from files WHERE direction = 'INCOMING' and type = 'CSV' AND created > '2021-08-02' and name like '%ALLACHTRANS_AWX_HK%' and content like '%5032%'
