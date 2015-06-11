SELECT clockno,SUM(CASE WHEN ct.type = 'Normal Time' 
	       THEN er.rate*date_part('hour', checkout - checkin)
	       WHEN ct.type = 'Over Time'
	       THEN er.rate*date_part('hour', checkout - checkin) * 1.5
	       WHEN ct.type = 'Double Time'
	       THEN er.rate*date_part('hour', checkout - checkin) * 2
	       END)
from timesheet t 
inner join client_work_hours cw on 
	t.client_id = cw.client_id 
inner join work_hours_type ct on 
	ct.id = cw.hour_type
inner join employee_rate er on
       er.emp_no =  t.clockno
group by t.clockno

SELECT clockno,CASE WHEN ct.type = 'Normal Time' 
	       THEN er.rate*date_part('hour', checkout - checkin)
	       WHEN ct.type = 'Over Time'
	       THEN er.rate*date_part('hour', checkout - checkin) * 1.5
	       WHEN ct.type = 'Double Time'
	       THEN er.rate*date_part('hour', checkout - checkin) * 2
	       END
from timesheet t 
inner join client_work_hours cw on 
	t.client_id = cw.client_id 
inner join work_hours_type ct on 
	ct.id = cw.hour_type
inner join employee_rate er on
       er.emp_no =  t.clockno
group by t.clockno

select clockno,round(sum(sp_calc_pay(timeid, clockno)),2) as pay,checkin::date as timesheet_day 
from timesheet 
group by 1,3;

