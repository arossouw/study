create function sp_calc_pay(timeid_l integer,clockno_l integer) RETURNS numeric AS $$
DECLARE
	l_employee_hourly numeric := 0.0;
	l_employee_category varchar := '';
	employee_pay numeric := 0.0;
	l_day timestamp := now();
	l_day_of_week varchar := '';
BEGIN
	SELECT checkin into l_day from timesheet where timeid = timeid_l;
	SELECT to_char(checkin::date, 'Day') INTO l_day_of_week from timesheet where timeid = timeid_l;
	SELECT rate INTO l_employee_hourly FROM employee_hourly where clockno =clockno_l;
	SELECT trim(to_char(l_day::date, 'Day')) INTO l_day_of_week;

	SELECT l_employee_hourly * EXTRACT(EPOCH FROM checkout - checkin) / 3600
		INTO employee_pay
		FROM timesheet WHERE timeid = timeid_l;

	IF l_day::time > '16:30:00' AND l_day_of_week <> 'Sunday' THEN 
		RETURN employee_pay * 1.5;
	END IF;
	
	IF l_day_of_week = 'Sunday' THEN
		RETURN employee_pay * 2;
	END IF;

	RETURN employee_pay;
END;
$$ LANGUAGE plpgsql;
