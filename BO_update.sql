-- Run1
-- update rank, own_salesperson, customer_tel
update tabSME_BO_and_Plan 
	set rank_S_date = case when rank_update = 'S' then date_format(modified, '%Y-%m-%d') else rank_S_date end,
	rank_A_date = case when rank_update = 'A' then date_format(modified, '%Y-%m-%d') else rank_A_date end,
	rank_B_date = case when rank_update = 'B' then date_format(modified, '%Y-%m-%d') else rank_B_date end,
	rank_C_date = case when rank_update = 'C' then date_format(modified, '%Y-%m-%d') else rank_C_date end,
	rank_update = case when contract_status = 'Contracted' then 'S' else rank_update end,
	ringi_status = case when contract_status = 'Contracted' then 'Approved' else ringi_status end,
	visit_or_not = case when contract_status = 'Contracted' then 'Yes - ຢ້ຽມຢາມແລ້ວ' when visit_date > date(now()) and visit_or_not = 'Yes - ຢ້ຽມຢາມແລ້ວ' then 'No - ຍັງບໍ່ໄດ້ລົງຢ້ຽມຢາມ' else visit_or_not end,
	rank1 = case when date_format(creation, '%Y-%m-%d') = date_format(modified, '%Y-%m-%d') then rank_update else rank1 end,
	`own_salesperson` = case when `own_salesperson` is not null then `own_salesperson` when callcenter_of_sales is null or callcenter_of_sales = '' then staff_no else regexp_replace(callcenter_of_sales  , '[^[:digit:]]', '') end,
	customer_tel = 
	case when customer_tel = '' then ''
		when (length (regexp_replace(customer_tel , '[^[:digit:]]', '')) = 11 and left (regexp_replace(customer_tel , '[^[:digit:]]', ''),3) = '020')
			or (length (regexp_replace(customer_tel , '[^[:digit:]]', '')) = 10 and left (regexp_replace(customer_tel , '[^[:digit:]]', ''),2) = '20')
			or (length (regexp_replace(customer_tel , '[^[:digit:]]', '')) = 8 and left (regexp_replace(customer_tel , '[^[:digit:]]', ''),1) in ('2','5','7','8','9'))
		then concat('9020',right(regexp_replace(customer_tel , '[^[:digit:]]', ''),8)) -- for 020
		when (length (regexp_replace(customer_tel , '[^[:digit:]]', '')) = 10 and left (regexp_replace(customer_tel , '[^[:digit:]]', ''),3) = '030')
			or (length (regexp_replace(customer_tel , '[^[:digit:]]', '')) = 9 and left (regexp_replace(customer_tel , '[^[:digit:]]', ''),2) = '30')
			or (length (regexp_replace(customer_tel , '[^[:digit:]]', '')) = 7 and left (regexp_replace(customer_tel , '[^[:digit:]]', ''),1) in ('2','4','5','7','9'))
		then concat('9030',right(regexp_replace(customer_tel , '[^[:digit:]]', ''),7)) -- for 030
		when left (right (regexp_replace(customer_tel , '[^[:digit:]]', ''),8),1) in ('0','1','') then concat('9030',right(regexp_replace(customer_tel , '[^[:digit:]]', ''),7))
		when left (right (regexp_replace(customer_tel , '[^[:digit:]]', ''),8),1) in ('2','5','7','8','9')
		then concat('9020',right(regexp_replace(customer_tel , '[^[:digit:]]', ''),8))
		else concat('9020',right(regexp_replace(customer_tel , '[^[:digit:]]', ''),8))
	end
;

 -- Run2
update tabsme_Sales_partner
	set broker_tel = 
	  case when broker_tel = '' then ''
		when (length (regexp_replace(broker_tel , '[^[:digit:]]', '')) = 11 and left (regexp_replace(broker_tel , '[^[:digit:]]', ''),3) = '020')
			or (length (regexp_replace(broker_tel , '[^[:digit:]]', '')) = 10 and left (regexp_replace(broker_tel , '[^[:digit:]]', ''),2) = '20')
			or (length (regexp_replace(broker_tel , '[^[:digit:]]', '')) = 8 and left (regexp_replace(broker_tel , '[^[:digit:]]', ''),1) in ('2','5','7','8','9'))
		then concat('9020',right(regexp_replace(broker_tel , '[^[:digit:]]', ''),8)) -- for 020
		when (length (regexp_replace(broker_tel , '[^[:digit:]]', '')) = 10 and left (regexp_replace(broker_tel , '[^[:digit:]]', ''),3) = '030')
			or (length (regexp_replace(broker_tel , '[^[:digit:]]', '')) = 9 and left (regexp_replace(broker_tel , '[^[:digit:]]', ''),2) = '30')
			or (length (regexp_replace(broker_tel , '[^[:digit:]]', '')) = 7 and left (regexp_replace(broker_tel , '[^[:digit:]]', ''),1) in ('2','4','5','7','9'))
		then concat('9030',right(regexp_replace(broker_tel , '[^[:digit:]]', ''),7)) -- for 030
		when left (right (regexp_replace(broker_tel , '[^[:digit:]]', ''),8),1) in ('0','1','') then concat('9030',right(regexp_replace(broker_tel , '[^[:digit:]]', ''),7))
		when left (right (regexp_replace(broker_tel , '[^[:digit:]]', ''),8),1) in ('2','5','7','8','9')
		then concat('9020',right(regexp_replace(broker_tel , '[^[:digit:]]', ''),8))
		else concat('9020',right(regexp_replace(broker_tel , '[^[:digit:]]', ''),8))
	end,
	broker_type = case when refer_type = 'LMS_Broker' then 'SP - ນາຍໜ້າໃນອາດີດ' else broker_type end,
	refer_type = case when broker_type = '5way - 5ສາຍພົວພັນ' and refer_type is null then '5way' else refer_type end
;


-- run 3

-- update backup data 
insert into tabSME_BO_and_Plan select * from tabSME_BO_and_Plan_bk where name not in (select name from tabSME_BO_and_Plan);
replace into tabSME_BO_and_Plan_bk select * from tabSME_BO_and_Plan; -- Updated Rows	495867
-- replace into tabsme_Sales_partner_bk select * from tabsme_Sales_partner; -- Updated Rows	151647


-- Run4

-- BO https://docs.google.com/spreadsheets/d/1rKhGY4JN5N0EZs8WiUC8dVxFAiwGrxcMp8-K_Scwlg4/edit#gid=1793628529&fvid=551853106
replace into SME_BO_and_Plan_report 
select case when bpr.date_report is null then date(now()) else bpr.date_report end `date_report`, sme.staff_no, 1 `case`, case when bp.`type` = 'New' then 'NEW' when bp.`type` = 'Dor' then 'DOR' when bp.`type` = 'Inc' then 'INC' end `type`,
	bp.usd_loan_amount, bp.case_no, bp.contract_no, -- bp.customer_name, 
	concat('=HYPERLINK("http://13.250.153.252:8000/app/sme_bo_and_plan/"&',bp.name,',', '"' , bp.customer_name, '"',')' ) `customer_name`,
	bp.rank_update,
	case when bp.contract_status = 'Contracted' then 'Contracted' when bp.contract_status = 'Cancelled' then 'Cancelled' 
		when bp.ringi_status = 'Approved' then 'APPROVED' when bp.ringi_status = 'Pending approval' then 'PENDING' 
		when bp.ringi_status = 'Draft' then 'DRAFT' when bp.ringi_status = 'Not Ringi' then 'No Ringi' 
	end `now_result`, 
	bp.disbursement_date_pay_date , 
	case when bpr.id is null and (bp.disbursement_date_pay_date is null or bp.disbursement_date_pay_date < date(now())) then null 
		when bp.disbursement_date_pay_date >= date(Now()) then 'ແຜນເພີ່ມ' when bpr.which is null then null
		when bpr.id is not null then 'ແຜນເພີ່ມ' else bpr.which
	end `which`, 
	bp.name `id`, case when bp.credit_remark is not null then bp.credit_remark else bp.contract_comment end `comments`
from tabSME_BO_and_Plan bp left join sme_org sme on (case when locate(' ', bp.staff_no) = 0 then bp.staff_no else left(bp.staff_no, locate(' ', bp.staff_no)-1) end = sme.staff_no)
left join SME_BO_and_Plan_report bpr on (bpr.id = bp.name)
where ((bp.rank_update in ('S','A','B','C') /*or bp.list_type is not null*/ )
	and case when bp.contract_status = 'Contracted' and bp.disbursement_date_pay_date < '2024-08-01' then 0 else 1 end != 0 -- if contracted before '2023-09-29' then not need
	-- and bp.disbursement_date_pay_date between date(now()) and '2024-07-31' -- and date_format(bp.modified, '%Y-%m-%d') >= date(now())
	-- and bp.ringi_status != 'Rejected' -- and bp.contract_status != 'Cancelled'
	) or bp.name in (select id from SME_BO_and_Plan_report)
order by sme.id ;

select * from SME_BO_and_Plan_report bpr -- where date_report = '2024-06-21';


-- _________________ delete in the last month sales plan but can't execute _________________
-- delete from SME_BO_and_Plan_report where now_result in ('Contracted', 'Cancelled') ;
-- delete from SME_BO_and_Plan_report where disbursement_date_pay_date < '2024-07-01' or disbursement_date_pay_date is null;
-- delete from SME_BO_and_Plan_report where id = 638551;

update SME_BO_and_Plan_report set which = null where now_result != 'Contracted' and disbursement_date_pay_date is null

-- Run 5
  
select bpr.* , case when bp.modified >= date(now()) then 'called' else 0 end `is_call_today`, sme.id 
from SME_BO_and_Plan_report bpr left join tabSME_BO_and_Plan bp on (bpr.id = bp.name)
left join sme_org sme on (case when locate(' ', bp.staff_no) = 0 then bp.staff_no else left(bp.staff_no, locate(' ', bp.staff_no)-1) end = sme.staff_no)
where bpr.which = 'ແຜນເພີ່ມ' and bpr.staff_no is not null -- and bpr.now_result = 'Contracted' and bpr.disbursement_date_pay_date is null
order by sme.id asc ;
