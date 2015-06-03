--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: mysqllink(text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION mysqllink(dbconn text, qry text, isinputfile boolean) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
declare _rec record;
declare _restable text;
begin  
  _restable = sqllink('mysql', dbconn, qry, isinputfile);
  if _restable is null then return; end if;
  
  for _rec in execute 'select * from ' || _restable loop
    return next _rec;
  end loop;
  
  return;
end;
$$;


ALTER FUNCTION public.mysqllink(dbconn text, qry text, isinputfile boolean) OWNER TO postgres;

--
-- Name: sp_calc_hours_ts(timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: arno
--

CREATE FUNCTION sp_calc_hours_ts(time_start timestamp without time zone, time_end timestamp without time zone) RETURNS real
    LANGUAGE plpgsql
    AS $_$
	BEGIN
		RETURN EXTRACT(EPOCH from $2- $1) / 3600;
	END;
$_$;


ALTER FUNCTION public.sp_calc_hours_ts(time_start timestamp without time zone, time_end timestamp without time zone) OWNER TO arno;

--
-- Name: sp_quate(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_quate(asqltxt text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
   return ''' || decode(asqltxt,escape) || ''';
end;
$$;


ALTER FUNCTION public.sp_quate(asqltxt text) OWNER TO postgres;

--
-- Name: sp_quote(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sp_quote(asqltxt text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
  return '''' || decode(asqltxt, 'escape') || '''';
end;
$$;


ALTER FUNCTION public.sp_quote(asqltxt text) OWNER TO postgres;

--
-- Name: sqllink(text, text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sqllink(sqltool text, dbconn text, qry text, isinputfile boolean) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare _tmpres text;
declare _tmptablecopyidx int;
declare _tmptablename text;
declare _bogus int;
begin
  _tmpres = sqlpylink(sqltool, dbconn, coalesce(qry,''), isinputfile);
  
  if not (_tmpres like '%create temporary table%') then
    if _tmpres is null or _tmpres = '' then
      return null;
    end if;
    raise Exception '%', _tmpres;
  end if;
  
  _tmptablename = sqltool || 'link_' || split_part(_tmpres, E'\n', 1); -- assuming column count is in the first line
  _tmpres = replace(_tmpres, '_tmptablename_', _tmptablename);
  
  begin
    execute 'delete from ' || _tmptablename;
  exception when others then
    execute split_part(_tmpres, E'\n', 2);  -- assuming create table is in the second line
  end;
  
  _tmptablecopyidx = position('COPY' in _tmpres);
  execute substring(_tmpres, _tmptablecopyidx);
  
  return _tmptablename;
 end;
$$;


ALTER FUNCTION public.sqllink(sqltool text, dbconn text, qry text, isinputfile boolean) OWNER TO postgres;

--
-- Name: sqlpylink(text, text, character varying, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sqlpylink(sqltool text, dbconn text, aquery character varying, isinputifle boolean) RETURNS text
    LANGUAGE plpythonu
    AS $$
  import os
  import uuid
  
  from datetime import datetime, date, time
  from itertools import islice
  
  tmpfile = '/tmp/%slink%s.txt' % (sqltool, uuid.uuid4())
  
  os.system('echo "%s sqlpylink(%s, %s, %s, %s)" >> /tmp/mysqllink_debug.txt' % (datetime.utcnow().strftime('%Y%m%d%H%M%S'), sqltool, dbconn, aquery, isinputifle))
  
  try:
    if isinputifle != True:
      res = os.system('echo "%s" | %s %s > %s 2>&1' % (aquery.replace('"', '\\"'), sqltool, dbconn, tmpfile))
      os.system('echo "%s %s | %s %s > %s 2>&1 " >> /tmp/mysqllink_debug.txt' % (datetime.utcnow().strftime('%Y%m%d%H%M%S'), aquery.replace('"', '\\"'), sqltool, dbconn, tmpfile))
    else:
      res = os.system('cat %s | %s %s > %s 2>&1' % (query, sqltool, dbconn, tmpfile))
      os.system('echo "%s cat %s | %s %s > %s 2>&1" >> /tmp/mysqllink_debug.txt' % (datetime.utcnow().strftime('%Y%m%d%H%M%S'), query, sqltool, dbconn, tmpfile))
    fin = open('%s' % tmpfile, 'rt')
  except Exception as ex:
    return 'aquery Execute Error, %d %s %s %s %s' % (res, ex, sqltool, dbconn, tmpfile)
  
  result = ''
  
  if res != 0:
    result = fin.read()
    fin.close()
    os.system('rm -f %s' % tmpfile)
    return result
    
  try:
    headers = list(islice(fin, 1))
    fin.close()
    if len(headers) == 0:
      return ''
    result = str(len(headers[0].split('\t')))
    result = "%s\ncreate temporary table _tmptablename_ (%s);" % (result, headers[0].replace(' ', '_').replace('\n', ' text').replace('\t', ' text,'))
    result = "%s\nCOPY _tmptablename_ FROM '%s' delimiter as '\t' null as 'NULL' CSV HEADER;" % (result, tmpfile)
    result = "%s\nselect sqlpylink_cleanup('%s');" % (result, tmpfile)
  except Exception as ex:
    if fin != 0:
      fin.close()
    return ex  
  
  return result
$$;


ALTER FUNCTION public.sqlpylink(sqltool text, dbconn text, aquery character varying, isinputifle boolean) OWNER TO postgres;

--
-- Name: sqlpylink_cleanup(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION sqlpylink_cleanup(tmpfilename text) RETURNS text
    LANGUAGE plpythonu
    AS $$
  import os
  os.system('rm -f %s' % tmpfilename)
  return 'OK'
$$;


ALTER FUNCTION public.sqlpylink_cleanup(tmpfilename text) OWNER TO postgres;

--
-- Name: truncate_tables(character varying); Type: FUNCTION; Schema: public; Owner: arno
--

CREATE FUNCTION truncate_tables(username character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    statements CURSOR FOR
        SELECT tablename FROM pg_tables
        WHERE tableowner = username AND schemaname = 'public';
BEGIN
    FOR stmt IN statements LOOP
        EXECUTE 'TRUNCATE TABLE ' || quote_ident(stmt.tablename) || ' CASCADE;';
    END LOOP;
END;
$$;


ALTER FUNCTION public.truncate_tables(username character varying) OWNER TO arno;

--
-- Name: tsqllink(text, text, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION tsqllink(dbconn text, qry text, isinputfile boolean) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
declare _rec record;
declare _restable text;
begin  
  _restable = sqllink('tsql', dbconn, qry, isinputfile);
  if _restable is null then return; end if;
  
  for _rec in execute 'select * from ' || _restable loop
    return next _rec;
  end loop;
  
  return;
end;
$$;


ALTER FUNCTION public.tsqllink(dbconn text, qry text, isinputfile boolean) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_transaction; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE account_transaction (
    transaction_id integer NOT NULL,
    from_account_id integer,
    to_account_id integer,
    transaction_category integer,
    transaction_type_id integer
);


ALTER TABLE public.account_transaction OWNER TO arno;

--
-- Name: account_transaction_category; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE account_transaction_category (
    id integer NOT NULL,
    category character varying(30)
);


ALTER TABLE public.account_transaction_category OWNER TO arno;

--
-- Name: account_transaction_category_id_seq; Type: SEQUENCE; Schema: public; Owner: arno
--

CREATE SEQUENCE account_transaction_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_transaction_category_id_seq OWNER TO arno;

--
-- Name: account_transaction_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: arno
--

ALTER SEQUENCE account_transaction_category_id_seq OWNED BY account_transaction_category.id;


--
-- Name: account_transaction_type; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE account_transaction_type (
    id integer NOT NULL,
    type character(3)
);


ALTER TABLE public.account_transaction_type OWNER TO arno;

--
-- Name: account_transaction_type_id_seq; Type: SEQUENCE; Schema: public; Owner: arno
--

CREATE SEQUENCE account_transaction_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_transaction_type_id_seq OWNER TO arno;

--
-- Name: account_transaction_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: arno
--

ALTER SEQUENCE account_transaction_type_id_seq OWNED BY account_transaction_type.id;


--
-- Name: bank_account_type; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE bank_account_type (
    id integer NOT NULL,
    type character varying(20)
);


ALTER TABLE public.bank_account_type OWNER TO arno;

--
-- Name: bank_account_type_id_seq; Type: SEQUENCE; Schema: public; Owner: arno
--

CREATE SEQUENCE bank_account_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bank_account_type_id_seq OWNER TO arno;

--
-- Name: bank_account_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: arno
--

ALTER SEQUENCE bank_account_type_id_seq OWNED BY bank_account_type.id;


--
-- Name: client; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE client (
    client_id integer NOT NULL,
    client_name character varying(30)
);


ALTER TABLE public.client OWNER TO arno;

--
-- Name: client_account; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE client_account (
    client_id integer NOT NULL,
    account_type_id integer,
    account_no character varying(20),
    account_branch character varying(30),
    account_bank character varying(20)
);


ALTER TABLE public.client_account OWNER TO arno;

--
-- Name: client_branch; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE client_branch (
    client_id integer,
    branch_id integer NOT NULL,
    address text,
    branch_name character varying(40),
    phone character varying(15),
    email character varying(35)
);


ALTER TABLE public.client_branch OWNER TO arno;

--
-- Name: client_branch_branch_id_seq; Type: SEQUENCE; Schema: public; Owner: arno
--

CREATE SEQUENCE client_branch_branch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.client_branch_branch_id_seq OWNER TO arno;

--
-- Name: client_branch_branch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: arno
--

ALTER SEQUENCE client_branch_branch_id_seq OWNED BY client_branch.branch_id;


--
-- Name: client_client_id_seq; Type: SEQUENCE; Schema: public; Owner: arno
--

CREATE SEQUENCE client_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.client_client_id_seq OWNER TO arno;

--
-- Name: client_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: arno
--

ALTER SEQUENCE client_client_id_seq OWNED BY client.client_id;


--
-- Name: client_work_hours; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE client_work_hours (
    client_id integer NOT NULL,
    hour_type integer NOT NULL,
    time_start time without time zone,
    time_end time without time zone
);


ALTER TABLE public.client_work_hours OWNER TO postgres;

--
-- Name: department; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE department (
    dept_no integer NOT NULL,
    dept_name character varying(25)
);


ALTER TABLE public.department OWNER TO arno;

--
-- Name: department_dept_no_seq; Type: SEQUENCE; Schema: public; Owner: arno
--

CREATE SEQUENCE department_dept_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.department_dept_no_seq OWNER TO arno;

--
-- Name: department_dept_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: arno
--

ALTER SEQUENCE department_dept_no_seq OWNED BY department.dept_no;


--
-- Name: employee; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE employee (
    clockno integer NOT NULL,
    birth_date date,
    firstname character varying(40),
    lastname character varying(40),
    gender character(1),
    hire_date date NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.employee OWNER TO arno;

--
-- Name: employee_dept; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE employee_dept (
    clockno integer NOT NULL,
    dept_no integer
);


ALTER TABLE public.employee_dept OWNER TO arno;

--
-- Name: employee_rate; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE employee_rate (
    emp_no integer NOT NULL,
    rate numeric
);


ALTER TABLE public.employee_rate OWNER TO postgres;

--
-- Name: hr_deduction; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE hr_deduction (
    deductid integer NOT NULL,
    clockno integer NOT NULL,
    deductiontype character varying(20),
    amount real,
    note text
);


ALTER TABLE public.hr_deduction OWNER TO arno;

--
-- Name: hr_deduction_deductid_seq; Type: SEQUENCE; Schema: public; Owner: arno
--

CREATE SEQUENCE hr_deduction_deductid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hr_deduction_deductid_seq OWNER TO arno;

--
-- Name: hr_deduction_deductid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: arno
--

ALTER SEQUENCE hr_deduction_deductid_seq OWNED BY hr_deduction.deductid;


--
-- Name: hr_leave; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE hr_leave (
    approved_by integer NOT NULL,
    from_date date,
    to_date date,
    leave_type_id integer
);


ALTER TABLE public.hr_leave OWNER TO arno;

--
-- Name: hr_leave_type; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE hr_leave_type (
    id integer NOT NULL,
    leave_name character varying(20)
);


ALTER TABLE public.hr_leave_type OWNER TO arno;

--
-- Name: hr_leave_type_id_seq; Type: SEQUENCE; Schema: public; Owner: arno
--

CREATE SEQUENCE hr_leave_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hr_leave_type_id_seq OWNER TO arno;

--
-- Name: hr_leave_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: arno
--

ALTER SEQUENCE hr_leave_type_id_seq OWNED BY hr_leave_type.id;


--
-- Name: job_history; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE job_history (
    clockno integer NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL,
    title character varying(35)
);


ALTER TABLE public.job_history OWNER TO arno;

--
-- Name: job_payscale; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE job_payscale (
    id integer NOT NULL,
    title character varying(25) NOT NULL,
    skill_level integer NOT NULL,
    rate money
);


ALTER TABLE public.job_payscale OWNER TO postgres;

--
-- Name: job_payscale_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE job_payscale_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_payscale_id_seq OWNER TO postgres;

--
-- Name: job_payscale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE job_payscale_id_seq OWNED BY job_payscale.id;


--
-- Name: job_salary; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE job_salary (
    title character varying(20) NOT NULL,
    minimum money,
    maximum money,
    CONSTRAINT job_salary_check CHECK ((maximum > minimum))
);


ALTER TABLE public.job_salary OWNER TO arno;

--
-- Name: payroll; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE payroll (
    payroll_id integer NOT NULL,
    employee_id integer NOT NULL,
    hoursworked integer,
    grosspay real,
    deductions real,
    netpay real
);


ALTER TABLE public.payroll OWNER TO arno;

--
-- Name: payroll_payroll_id_seq; Type: SEQUENCE; Schema: public; Owner: arno
--

CREATE SEQUENCE payroll_payroll_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payroll_payroll_id_seq OWNER TO arno;

--
-- Name: payroll_payroll_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: arno
--

ALTER SEQUENCE payroll_payroll_id_seq OWNED BY payroll.payroll_id;


--
-- Name: timesheet; Type: TABLE; Schema: public; Owner: arno; Tablespace: 
--

CREATE TABLE timesheet (
    timeid integer NOT NULL,
    clockno integer NOT NULL,
    checkin timestamp without time zone,
    checkout timestamp without time zone,
    description character varying(30),
    client_id integer
);


ALTER TABLE public.timesheet OWNER TO arno;

--
-- Name: timesheet_timeid_seq; Type: SEQUENCE; Schema: public; Owner: arno
--

CREATE SEQUENCE timesheet_timeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timesheet_timeid_seq OWNER TO arno;

--
-- Name: timesheet_timeid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: arno
--

ALTER SEQUENCE timesheet_timeid_seq OWNED BY timesheet.timeid;


--
-- Name: work_hours_type; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE work_hours_type (
    id integer NOT NULL,
    type character varying(15) NOT NULL
);


ALTER TABLE public.work_hours_type OWNER TO postgres;

--
-- Name: work_hours_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE work_hours_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.work_hours_type_id_seq OWNER TO postgres;

--
-- Name: work_hours_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE work_hours_type_id_seq OWNED BY work_hours_type.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: arno
--

ALTER TABLE ONLY account_transaction_category ALTER COLUMN id SET DEFAULT nextval('account_transaction_category_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: arno
--

ALTER TABLE ONLY account_transaction_type ALTER COLUMN id SET DEFAULT nextval('account_transaction_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: arno
--

ALTER TABLE ONLY bank_account_type ALTER COLUMN id SET DEFAULT nextval('bank_account_type_id_seq'::regclass);


--
-- Name: client_id; Type: DEFAULT; Schema: public; Owner: arno
--

ALTER TABLE ONLY client ALTER COLUMN client_id SET DEFAULT nextval('client_client_id_seq'::regclass);


--
-- Name: branch_id; Type: DEFAULT; Schema: public; Owner: arno
--

ALTER TABLE ONLY client_branch ALTER COLUMN branch_id SET DEFAULT nextval('client_branch_branch_id_seq'::regclass);


--
-- Name: dept_no; Type: DEFAULT; Schema: public; Owner: arno
--

ALTER TABLE ONLY department ALTER COLUMN dept_no SET DEFAULT nextval('department_dept_no_seq'::regclass);


--
-- Name: deductid; Type: DEFAULT; Schema: public; Owner: arno
--

ALTER TABLE ONLY hr_deduction ALTER COLUMN deductid SET DEFAULT nextval('hr_deduction_deductid_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: arno
--

ALTER TABLE ONLY hr_leave_type ALTER COLUMN id SET DEFAULT nextval('hr_leave_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY job_payscale ALTER COLUMN id SET DEFAULT nextval('job_payscale_id_seq'::regclass);


--
-- Name: payroll_id; Type: DEFAULT; Schema: public; Owner: arno
--

ALTER TABLE ONLY payroll ALTER COLUMN payroll_id SET DEFAULT nextval('payroll_payroll_id_seq'::regclass);


--
-- Name: timeid; Type: DEFAULT; Schema: public; Owner: arno
--

ALTER TABLE ONLY timesheet ALTER COLUMN timeid SET DEFAULT nextval('timesheet_timeid_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY work_hours_type ALTER COLUMN id SET DEFAULT nextval('work_hours_type_id_seq'::regclass);


--
-- Data for Name: account_transaction; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY account_transaction (transaction_id, from_account_id, to_account_id, transaction_category, transaction_type_id) FROM stdin;
\.


--
-- Data for Name: account_transaction_category; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY account_transaction_category (id, category) FROM stdin;
\.


--
-- Name: account_transaction_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: arno
--

SELECT pg_catalog.setval('account_transaction_category_id_seq', 1, false);


--
-- Data for Name: account_transaction_type; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY account_transaction_type (id, type) FROM stdin;
\.


--
-- Name: account_transaction_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: arno
--

SELECT pg_catalog.setval('account_transaction_type_id_seq', 1, false);


--
-- Data for Name: bank_account_type; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY bank_account_type (id, type) FROM stdin;
\.


--
-- Name: bank_account_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: arno
--

SELECT pg_catalog.setval('bank_account_type_id_seq', 1, false);


--
-- Data for Name: client; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY client (client_id, client_name) FROM stdin;
1	ACOMPANY
\.


--
-- Data for Name: client_account; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY client_account (client_id, account_type_id, account_no, account_branch, account_bank) FROM stdin;
\.


--
-- Data for Name: client_branch; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY client_branch (client_id, branch_id, address, branch_name, phone, email) FROM stdin;
\.


--
-- Name: client_branch_branch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: arno
--

SELECT pg_catalog.setval('client_branch_branch_id_seq', 1, false);


--
-- Name: client_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: arno
--

SELECT pg_catalog.setval('client_client_id_seq', 1, true);


--
-- Data for Name: client_work_hours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY client_work_hours (client_id, hour_type, time_start, time_end) FROM stdin;
1	2	16:30:00	19:30:00
1	1	08:00:00	16:30:00
\.


--
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY department (dept_no, dept_name) FROM stdin;
1	IT
2	Human Resources
\.


--
-- Name: department_dept_no_seq; Type: SEQUENCE SET; Schema: public; Owner: arno
--

SELECT pg_catalog.setval('department_dept_no_seq', 1, true);


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY employee (clockno, birth_date, firstname, lastname, gender, hire_date, active) FROM stdin;
2665	1981-06-09	Arno	Rossouw	M	2008-03-04	t
2669	1983-10-20	Daniel	Rossouw	M	2015-01-01	t
3000	1959-05-20	Adeline	Faraday	F	2005-06-01	t
\.


--
-- Data for Name: employee_dept; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY employee_dept (clockno, dept_no) FROM stdin;
2665	1
3000	2
\.


--
-- Data for Name: employee_rate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY employee_rate (emp_no, rate) FROM stdin;
2665	148.00
\.


--
-- Data for Name: hr_deduction; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY hr_deduction (deductid, clockno, deductiontype, amount, note) FROM stdin;
\.


--
-- Name: hr_deduction_deductid_seq; Type: SEQUENCE SET; Schema: public; Owner: arno
--

SELECT pg_catalog.setval('hr_deduction_deductid_seq', 1, true);


--
-- Data for Name: hr_leave; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY hr_leave (approved_by, from_date, to_date, leave_type_id) FROM stdin;
3000	2015-04-01	2015-04-20	3
\.


--
-- Data for Name: hr_leave_type; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY hr_leave_type (id, leave_name) FROM stdin;
3	Sick Leave
4	Study Leave
5	Maternal Leave
6	Paternal Leave
7	Compassionate Leave
\.


--
-- Name: hr_leave_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: arno
--

SELECT pg_catalog.setval('hr_leave_type_id_seq', 4, true);


--
-- Data for Name: job_history; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY job_history (clockno, from_date, to_date, title) FROM stdin;
\.


--
-- Data for Name: job_payscale; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY job_payscale (id, title, skill_level, rate) FROM stdin;
\.


--
-- Name: job_payscale_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('job_payscale_id_seq', 1, false);


--
-- Data for Name: job_salary; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY job_salary (title, minimum, maximum) FROM stdin;
\.


--
-- Data for Name: payroll; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY payroll (payroll_id, employee_id, hoursworked, grosspay, deductions, netpay) FROM stdin;
\.


--
-- Name: payroll_payroll_id_seq; Type: SEQUENCE SET; Schema: public; Owner: arno
--

SELECT pg_catalog.setval('payroll_payroll_id_seq', 1, false);


--
-- Data for Name: timesheet; Type: TABLE DATA; Schema: public; Owner: arno
--

COPY timesheet (timeid, clockno, checkin, checkout, description, client_id) FROM stdin;
1	2665	2015-06-01 08:00:00	2015-06-01 16:00:00	DBA - NORMAL TIME	1
2	2665	2016-06-01 08:00:00	2016-06-01 16:30:00	DBA - NORMAL TIME	1
\.


--
-- Name: timesheet_timeid_seq; Type: SEQUENCE SET; Schema: public; Owner: arno
--

SELECT pg_catalog.setval('timesheet_timeid_seq', 2, true);


--
-- Data for Name: work_hours_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY work_hours_type (id, type) FROM stdin;
1	Normal Time
2	Over Time
3	Double Time
\.


--
-- Name: work_hours_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('work_hours_type_id_seq', 3, true);


--
-- Name: account_transaction_category_category_key; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY account_transaction_category
    ADD CONSTRAINT account_transaction_category_category_key UNIQUE (category);


--
-- Name: account_transaction_category_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY account_transaction_category
    ADD CONSTRAINT account_transaction_category_pkey PRIMARY KEY (id);


--
-- Name: account_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY account_transaction
    ADD CONSTRAINT account_transaction_pkey PRIMARY KEY (transaction_id);


--
-- Name: account_transaction_type_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY account_transaction_type
    ADD CONSTRAINT account_transaction_type_pkey PRIMARY KEY (id);


--
-- Name: bank_account_type_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY bank_account_type
    ADD CONSTRAINT bank_account_type_pkey PRIMARY KEY (id);


--
-- Name: bank_account_type_type_key; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY bank_account_type
    ADD CONSTRAINT bank_account_type_type_key UNIQUE (type);


--
-- Name: client_account_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY client_account
    ADD CONSTRAINT client_account_pkey PRIMARY KEY (client_id);


--
-- Name: client_branch_branch_name_key; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY client_branch
    ADD CONSTRAINT client_branch_branch_name_key UNIQUE (branch_name);


--
-- Name: client_branch_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY client_branch
    ADD CONSTRAINT client_branch_pkey PRIMARY KEY (branch_id);


--
-- Name: client_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- Name: department_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY department
    ADD CONSTRAINT department_pkey PRIMARY KEY (dept_no);


--
-- Name: employee_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (clockno);


--
-- Name: hr_deduction_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY hr_deduction
    ADD CONSTRAINT hr_deduction_pkey PRIMARY KEY (deductid);


--
-- Name: hr_leave_type_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY hr_leave_type
    ADD CONSTRAINT hr_leave_type_pkey PRIMARY KEY (id);


--
-- Name: job_payscale_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY job_payscale
    ADD CONSTRAINT job_payscale_pkey PRIMARY KEY (id);


--
-- Name: job_salary_title_key; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY job_salary
    ADD CONSTRAINT job_salary_title_key UNIQUE (title);


--
-- Name: payroll_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY payroll
    ADD CONSTRAINT payroll_pkey PRIMARY KEY (payroll_id);


--
-- Name: timesheet_pkey; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY timesheet
    ADD CONSTRAINT timesheet_pkey PRIMARY KEY (timeid);


--
-- Name: un_leave_name; Type: CONSTRAINT; Schema: public; Owner: arno; Tablespace: 
--

ALTER TABLE ONLY hr_leave_type
    ADD CONSTRAINT un_leave_name UNIQUE (leave_name);


--
-- Name: work_hours_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY work_hours_type
    ADD CONSTRAINT work_hours_type_pkey PRIMARY KEY (id);


--
-- Name: work_hours_type_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY work_hours_type
    ADD CONSTRAINT work_hours_type_type_key UNIQUE (type);


--
-- Name: account_transaction_transaction_category_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY account_transaction
    ADD CONSTRAINT account_transaction_transaction_category_fkey FOREIGN KEY (transaction_category) REFERENCES account_transaction_category(id);


--
-- Name: account_transaction_transaction_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY account_transaction
    ADD CONSTRAINT account_transaction_transaction_type_id_fkey FOREIGN KEY (transaction_type_id) REFERENCES account_transaction_type(id);


--
-- Name: client_account_account_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY client_account
    ADD CONSTRAINT client_account_account_type_id_fkey FOREIGN KEY (account_type_id) REFERENCES bank_account_type(id);


--
-- Name: client_branch_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY client_branch
    ADD CONSTRAINT client_branch_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(client_id);


--
-- Name: client_work_hours_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_work_hours
    ADD CONSTRAINT client_work_hours_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(client_id);


--
-- Name: client_work_hours_hour_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY client_work_hours
    ADD CONSTRAINT client_work_hours_hour_type_fkey FOREIGN KEY (hour_type) REFERENCES work_hours_type(id);


--
-- Name: employee_dept_clockno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY employee_dept
    ADD CONSTRAINT employee_dept_clockno_fkey FOREIGN KEY (clockno) REFERENCES employee(clockno);


--
-- Name: employee_dept_dept_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY employee_dept
    ADD CONSTRAINT employee_dept_dept_no_fkey FOREIGN KEY (dept_no) REFERENCES department(dept_no);


--
-- Name: employee_rate_emp_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY employee_rate
    ADD CONSTRAINT employee_rate_emp_no_fkey FOREIGN KEY (emp_no) REFERENCES employee(clockno);


--
-- Name: hr_deduction_clockno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY hr_deduction
    ADD CONSTRAINT hr_deduction_clockno_fkey FOREIGN KEY (clockno) REFERENCES employee(clockno);


--
-- Name: hr_leave_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY hr_leave
    ADD CONSTRAINT hr_leave_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES employee(clockno);


--
-- Name: hr_leave_leave_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY hr_leave
    ADD CONSTRAINT hr_leave_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES hr_leave_type(id);


--
-- Name: job_history_clockno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY job_history
    ADD CONSTRAINT job_history_clockno_fkey FOREIGN KEY (clockno) REFERENCES employee(clockno);


--
-- Name: payroll_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY payroll
    ADD CONSTRAINT payroll_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employee(clockno);


--
-- Name: timesheet_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY timesheet
    ADD CONSTRAINT timesheet_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(client_id);


--
-- Name: timesheet_clockno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: arno
--

ALTER TABLE ONLY timesheet
    ADD CONSTRAINT timesheet_clockno_fkey FOREIGN KEY (clockno) REFERENCES employee(clockno);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: hr_leave; Type: ACL; Schema: public; Owner: arno
--

REVOKE ALL ON TABLE hr_leave FROM PUBLIC;
REVOKE ALL ON TABLE hr_leave FROM arno;
GRANT ALL ON TABLE hr_leave TO arno;


--
-- Name: hr_leave_type; Type: ACL; Schema: public; Owner: arno
--

REVOKE ALL ON TABLE hr_leave_type FROM PUBLIC;
REVOKE ALL ON TABLE hr_leave_type FROM arno;
GRANT ALL ON TABLE hr_leave_type TO arno;


--
-- PostgreSQL database dump complete
--

