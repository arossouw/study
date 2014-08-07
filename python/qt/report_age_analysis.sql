select gc.AccountNo, gc.ClientName,

pi_age.*

from gen_Client gc

left join (
  select pi.ClientKey,
  sum(case when (to_days(current_date) - to_days(cast(concat(pi.AccountingYear, '-', pi.AccountingMonth, '-01') as date))) <= 30 then round(sp_calc_invoice_balance(pi.IKey), 2) else 0 end) as 30day,
  sum(case when (to_days(current_date) - to_days(cast(concat(pi.AccountingYear, '-', pi.AccountingMonth, '-01') as date))) between 31 and 60 then round(sp_calc_invoice_balance(pi.IKey), 2) else 0 end) as 60day,
  sum(case when (to_days(current_date) - to_days(cast(concat(pi.AccountingYear, '-', pi.AccountingMonth, '-01') as date))) between 61 and 90 then round(sp_calc_invoice_balance(pi.IKey), 2) else 0 end) as 90day,
  sum(case when (to_days(current_date) - to_days(cast(concat(pi.AccountingYear, '-', pi.AccountingMonth, '-01') as date))) between 91 and 120 then round(sp_calc_invoice_balance(pi.IKey), 2) else 0 end) as 120day,
  sum(case when (to_days(current_date) - to_days(cast(concat(pi.AccountingYear, '-', pi.AccountingMonth, '-01') as date))) between 121 and 150 then round(sp_calc_invoice_balance(pi.IKey), 2) else 0 end) as 150day,
  sum(case when (to_days(current_date) - to_days(cast(concat(pi.AccountingYear, '-', pi.AccountingMonth, '-01') as date))) between 151 and 180 then round(sp_calc_invoice_balance(pi.IKey), 2) else 0 end) as 180day,
  sum(case when (to_days(current_date) - to_days(cast(concat(pi.AccountingYear, '-', pi.AccountingMonth, '-01') as date))) between 181 and 210 then round(sp_calc_invoice_balance(pi.IKey), 2) else 0 end) as 210day,
  sum(case when (to_days(current_date) - to_days(cast(concat(pi.AccountingYear, '-', pi.AccountingMonth, '-01') as date))) between 211 and 365 then round(sp_calc_invoice_balance(pi.IKey), 2) else 0 end) as 365day,
  sum(case when (to_days(current_date) - to_days(cast(concat(pi.AccountingYear, '-', pi.AccountingMonth, '-01') as date))) > 365 then round(sp_calc_invoice_balance(pi.IKey), 2) else 0 end) as over365day
  
  from pay_Invoices pi
  where pi.PaidUp = false
  group by pi.ClientKey
  
) pi_age on pi_age.ClientKey = gc.ClientKey

where exists(select * from pay_Invoices pi where pi.ClientKey = gc.ClientKey and pi.PaidUp = false)

order by upper(gc.ClientName), gc.AccountNo
;
