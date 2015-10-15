--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: payroll_dev; Type: SCHEMA; Schema: -; Owner: arossouw
--

CREATE SCHEMA payroll_dev;


ALTER SCHEMA payroll_dev OWNER TO arossouw;

SET search_path = payroll_dev, pg_catalog;

--
-- Name: sp_calc_pay(integer, integer); Type: FUNCTION; Schema: payroll_dev; Owner: arossouw
--

CREATE FUNCTION sp_calc_pay(timeid_l integer, clockno_l integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION payroll_dev.sp_calc_pay(timeid_l integer, clockno_l integer) OWNER TO arossouw;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: account_transaction; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE account_transaction (
    transaction_id integer NOT NULL,
    from_account_id integer,
    to_account_id integer,
    transaction_category integer,
    transaction_type_id integer
);


ALTER TABLE account_transaction OWNER TO arossouw;

--
-- Name: account_transaction_category; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE account_transaction_category (
    id integer NOT NULL,
    category character varying(30)
);


ALTER TABLE account_transaction_category OWNER TO arossouw;

--
-- Name: account_transaction_category_id_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE account_transaction_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE account_transaction_category_id_seq OWNER TO arossouw;

--
-- Name: account_transaction_category_id_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE account_transaction_category_id_seq OWNED BY account_transaction_category.id;


--
-- Name: account_transaction_type; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE account_transaction_type (
    id integer NOT NULL,
    type character(3)
);


ALTER TABLE account_transaction_type OWNER TO arossouw;

--
-- Name: account_transaction_type_id_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE account_transaction_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE account_transaction_type_id_seq OWNER TO arossouw;

--
-- Name: account_transaction_type_id_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE account_transaction_type_id_seq OWNED BY account_transaction_type.id;


--
-- Name: bank_account_type; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE bank_account_type (
    id integer NOT NULL,
    type character varying(20) NOT NULL
);


ALTER TABLE bank_account_type OWNER TO arossouw;

--
-- Name: bank_account_type_id_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE bank_account_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bank_account_type_id_seq OWNER TO arossouw;

--
-- Name: bank_account_type_id_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE bank_account_type_id_seq OWNED BY bank_account_type.id;


--
-- Name: bank_name; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE bank_name (
    id integer NOT NULL,
    bank_name character varying(20) NOT NULL
);


ALTER TABLE bank_name OWNER TO arossouw;

--
-- Name: bank_name_id_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE bank_name_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bank_name_id_seq OWNER TO arossouw;

--
-- Name: bank_name_id_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE bank_name_id_seq OWNED BY bank_name.id;


--
-- Name: client; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE client (
    client_id integer NOT NULL,
    client_name character varying(30) NOT NULL
);


ALTER TABLE client OWNER TO arossouw;

--
-- Name: client_account; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE client_account (
    client_id integer NOT NULL,
    bank_account_type_id integer NOT NULL,
    account_no character varying(20) NOT NULL,
    account_branch character varying(30) NOT NULL,
    account_bankname integer NOT NULL
);


ALTER TABLE client_account OWNER TO arossouw;

--
-- Name: client_branch; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE client_branch (
    client_id integer NOT NULL,
    branch_id integer NOT NULL,
    address text NOT NULL,
    branch_name character varying(40) NOT NULL,
    phone character varying(15),
    email character varying(35)
);


ALTER TABLE client_branch OWNER TO arossouw;

--
-- Name: client_branch_branch_id_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE client_branch_branch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_branch_branch_id_seq OWNER TO arossouw;

--
-- Name: client_branch_branch_id_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE client_branch_branch_id_seq OWNED BY client_branch.branch_id;


--
-- Name: client_client_id_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE client_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE client_client_id_seq OWNER TO arossouw;

--
-- Name: client_client_id_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE client_client_id_seq OWNED BY client.client_id;


--
-- Name: company_bank_account; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE company_bank_account (
    bank_account_type_id integer NOT NULL,
    account_no character varying(30) NOT NULL,
    account_branch character varying(30) NOT NULL,
    account_bank character varying(30) NOT NULL
);


ALTER TABLE company_bank_account OWNER TO arossouw;

--
-- Name: company_deduction; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE company_deduction (
    deductdate date NOT NULL,
    deduction_type integer NOT NULL,
    amount numeric(8,3),
    employee_id integer NOT NULL
);


ALTER TABLE company_deduction OWNER TO arossouw;

--
-- Name: company_deduction_type; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE company_deduction_type (
    id integer NOT NULL,
    description character varying(35) NOT NULL
);


ALTER TABLE company_deduction_type OWNER TO arossouw;

--
-- Name: company_deduction_type_id_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE company_deduction_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE company_deduction_type_id_seq OWNER TO arossouw;

--
-- Name: company_deduction_type_id_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE company_deduction_type_id_seq OWNED BY company_deduction_type.id;


--
-- Name: department; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE department (
    dept_no integer NOT NULL,
    dept_name character varying(25) NOT NULL
);


ALTER TABLE department OWNER TO arossouw;

--
-- Name: department_dept_no_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE department_dept_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE department_dept_no_seq OWNER TO arossouw;

--
-- Name: department_dept_no_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE department_dept_no_seq OWNED BY department.dept_no;


--
-- Name: employee; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
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


ALTER TABLE employee OWNER TO arossouw;

--
-- Name: employee_bank_account; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE employee_bank_account (
    emp_no integer NOT NULL,
    bank_account_type_id integer NOT NULL,
    account_no character varying(20) NOT NULL,
    account_branch character varying(20) NOT NULL,
    account_bankname integer NOT NULL
);


ALTER TABLE employee_bank_account OWNER TO arossouw;

--
-- Name: employee_category; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE employee_category (
    clockno integer NOT NULL,
    category_name character varying(30) NOT NULL
);


ALTER TABLE employee_category OWNER TO arossouw;

--
-- Name: employee_deduction; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE employee_deduction (
    clockno integer NOT NULL,
    deductiontype integer NOT NULL,
    amount real NOT NULL,
    deductiondate date NOT NULL
);


ALTER TABLE employee_deduction OWNER TO arossouw;

--
-- Name: employee_deduction_type; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE employee_deduction_type (
    id integer NOT NULL,
    description character varying(35) NOT NULL
);


ALTER TABLE employee_deduction_type OWNER TO arossouw;

--
-- Name: employee_deduction_type_id_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE employee_deduction_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employee_deduction_type_id_seq OWNER TO arossouw;

--
-- Name: employee_deduction_type_id_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE employee_deduction_type_id_seq OWNED BY employee_deduction_type.id;


--
-- Name: employee_dept; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE employee_dept (
    clockno integer NOT NULL,
    dept_no integer NOT NULL
);


ALTER TABLE employee_dept OWNER TO arossouw;

--
-- Name: employee_leave; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE employee_leave (
    approved_by integer NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL,
    leave_type_id integer NOT NULL,
    CONSTRAINT employee_leave_check CHECK ((from_date < to_date))
);


ALTER TABLE employee_leave OWNER TO arossouw;

--
-- Name: employee_leave_type; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE employee_leave_type (
    id integer NOT NULL,
    leave_type character varying(15) NOT NULL
);


ALTER TABLE employee_leave_type OWNER TO arossouw;

--
-- Name: employee_leave_type_id_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE employee_leave_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employee_leave_type_id_seq OWNER TO arossouw;

--
-- Name: employee_leave_type_id_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE employee_leave_type_id_seq OWNED BY employee_leave_type.id;


--
-- Name: employee_salary; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE employee_salary (
    emp_no integer NOT NULL,
    salary_date date NOT NULL,
    netpay numeric(8,3) NOT NULL,
    grosspay numeric(8,3) NOT NULL
);


ALTER TABLE employee_salary OWNER TO arossouw;

--
-- Name: employment_history; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE employment_history (
    clockno integer NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL,
    title character varying(35) NOT NULL,
    CONSTRAINT employment_history_check CHECK ((from_date < to_date))
);


ALTER TABLE employment_history OWNER TO arossouw;

--
-- Name: payroll; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE payroll (
    payroll_id integer NOT NULL,
    employee_id integer NOT NULL,
    hoursworked integer NOT NULL,
    grosspay real NOT NULL,
    deductions real NOT NULL,
    netpay real NOT NULL
);


ALTER TABLE payroll OWNER TO arossouw;

--
-- Name: project; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE project (
    id integer NOT NULL,
    client_id integer NOT NULL,
    title character varying(30) NOT NULL,
    description character varying(45) NOT NULL,
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone,
    createdby integer NOT NULL,
    lastupdatedby integer NOT NULL
);


ALTER TABLE project OWNER TO arossouw;

--
-- Name: project_id_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE project_id_seq OWNER TO arossouw;

--
-- Name: project_id_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE project_id_seq OWNED BY project.id;


--
-- Name: timesheet; Type: TABLE; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

CREATE TABLE timesheet (
    timeid integer NOT NULL,
    clockno integer NOT NULL,
    checkin timestamp without time zone NOT NULL,
    checkout timestamp without time zone NOT NULL,
    description character varying(30) NOT NULL,
    project_id integer NOT NULL,
    CONSTRAINT timesheet_check CHECK ((checkout > checkin))
);


ALTER TABLE timesheet OWNER TO arossouw;

--
-- Name: timesheet_timeid_seq; Type: SEQUENCE; Schema: payroll_dev; Owner: arossouw
--

CREATE SEQUENCE timesheet_timeid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE timesheet_timeid_seq OWNER TO arossouw;

--
-- Name: timesheet_timeid_seq; Type: SEQUENCE OWNED BY; Schema: payroll_dev; Owner: arossouw
--

ALTER SEQUENCE timesheet_timeid_seq OWNED BY timesheet.timeid;


--
-- Name: id; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY account_transaction_category ALTER COLUMN id SET DEFAULT nextval('account_transaction_category_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY account_transaction_type ALTER COLUMN id SET DEFAULT nextval('account_transaction_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY bank_account_type ALTER COLUMN id SET DEFAULT nextval('bank_account_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY bank_name ALTER COLUMN id SET DEFAULT nextval('bank_name_id_seq'::regclass);


--
-- Name: client_id; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY client ALTER COLUMN client_id SET DEFAULT nextval('client_client_id_seq'::regclass);


--
-- Name: branch_id; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY client_branch ALTER COLUMN branch_id SET DEFAULT nextval('client_branch_branch_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY company_deduction_type ALTER COLUMN id SET DEFAULT nextval('company_deduction_type_id_seq'::regclass);


--
-- Name: dept_no; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY department ALTER COLUMN dept_no SET DEFAULT nextval('department_dept_no_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_deduction_type ALTER COLUMN id SET DEFAULT nextval('employee_deduction_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_leave_type ALTER COLUMN id SET DEFAULT nextval('employee_leave_type_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY project ALTER COLUMN id SET DEFAULT nextval('project_id_seq'::regclass);


--
-- Name: timeid; Type: DEFAULT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY timesheet ALTER COLUMN timeid SET DEFAULT nextval('timesheet_timeid_seq'::regclass);


--
-- Data for Name: account_transaction; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY account_transaction (transaction_id, from_account_id, to_account_id, transaction_category, transaction_type_id) FROM stdin;
\.


--
-- Data for Name: account_transaction_category; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY account_transaction_category (id, category) FROM stdin;
\.


--
-- Name: account_transaction_category_id_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('account_transaction_category_id_seq', 1, false);


--
-- Data for Name: account_transaction_type; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY account_transaction_type (id, type) FROM stdin;
\.


--
-- Name: account_transaction_type_id_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('account_transaction_type_id_seq', 1, false);


--
-- Data for Name: bank_account_type; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY bank_account_type (id, type) FROM stdin;
\.


--
-- Name: bank_account_type_id_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('bank_account_type_id_seq', 1, false);


--
-- Data for Name: bank_name; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY bank_name (id, bank_name) FROM stdin;
\.


--
-- Name: bank_name_id_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('bank_name_id_seq', 1, false);


--
-- Data for Name: client; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY client (client_id, client_name) FROM stdin;
\.


--
-- Data for Name: client_account; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY client_account (client_id, bank_account_type_id, account_no, account_branch, account_bankname) FROM stdin;
\.


--
-- Data for Name: client_branch; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY client_branch (client_id, branch_id, address, branch_name, phone, email) FROM stdin;
\.


--
-- Name: client_branch_branch_id_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('client_branch_branch_id_seq', 1, false);


--
-- Name: client_client_id_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('client_client_id_seq', 1, false);


--
-- Data for Name: company_bank_account; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY company_bank_account (bank_account_type_id, account_no, account_branch, account_bank) FROM stdin;
\.


--
-- Data for Name: company_deduction; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY company_deduction (deductdate, deduction_type, amount, employee_id) FROM stdin;
\.


--
-- Data for Name: company_deduction_type; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY company_deduction_type (id, description) FROM stdin;
1	Income Tax
2	UIF
3	Medical Aid Contribution
4	Travel Allowance
5	Cellphone Allowance
6	Medicare Tax
7	Employee Vacation
8	Sick Leave
9	Leave
10	Provident Fund
11	Retirement Fund
\.


--
-- Name: company_deduction_type_id_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('company_deduction_type_id_seq', 11, true);


--
-- Data for Name: department; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY department (dept_no, dept_name) FROM stdin;
\.


--
-- Name: department_dept_no_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('department_dept_no_seq', 1, false);


--
-- Data for Name: employee; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY employee (clockno, birth_date, firstname, lastname, gender, hire_date, active) FROM stdin;
2665	1981-06-09	Arno	Rossouw	M	2008-03-04	t
\.


--
-- Data for Name: employee_bank_account; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY employee_bank_account (emp_no, bank_account_type_id, account_no, account_branch, account_bankname) FROM stdin;
\.


--
-- Data for Name: employee_category; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY employee_category (clockno, category_name) FROM stdin;
2665	Database Administrator
\.


--
-- Data for Name: employee_deduction; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY employee_deduction (clockno, deductiontype, amount, deductiondate) FROM stdin;
\.


--
-- Data for Name: employee_deduction_type; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY employee_deduction_type (id, description) FROM stdin;
1	Income Tax
2	Medicare Tax
3	Severence Pay
7	UIF
8	Medical Aid Contribution
10	Loan
9	Workers Compensation
11	Garnishing Order
\.


--
-- Name: employee_deduction_type_id_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('employee_deduction_type_id_seq', 11, true);


--
-- Data for Name: employee_dept; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY employee_dept (clockno, dept_no) FROM stdin;
\.


--
-- Data for Name: employee_leave; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY employee_leave (approved_by, from_date, to_date, leave_type_id) FROM stdin;
\.


--
-- Data for Name: employee_leave_type; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY employee_leave_type (id, leave_type) FROM stdin;
\.


--
-- Name: employee_leave_type_id_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('employee_leave_type_id_seq', 1, false);


--
-- Data for Name: employee_salary; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY employee_salary (emp_no, salary_date, netpay, grosspay) FROM stdin;
\.


--
-- Data for Name: employment_history; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY employment_history (clockno, from_date, to_date, title) FROM stdin;
\.


--
-- Data for Name: payroll; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY payroll (payroll_id, employee_id, hoursworked, grosspay, deductions, netpay) FROM stdin;
\.


--
-- Data for Name: project; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY project (id, client_id, title, description, startdate, enddate, createdby, lastupdatedby) FROM stdin;
\.


--
-- Name: project_id_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('project_id_seq', 1, false);


--
-- Data for Name: timesheet; Type: TABLE DATA; Schema: payroll_dev; Owner: arossouw
--

COPY timesheet (timeid, clockno, checkin, checkout, description, project_id) FROM stdin;
\.


--
-- Name: timesheet_timeid_seq; Type: SEQUENCE SET; Schema: payroll_dev; Owner: arossouw
--

SELECT pg_catalog.setval('timesheet_timeid_seq', 1, false);


--
-- Name: account_transaction_category_category_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY account_transaction_category
    ADD CONSTRAINT account_transaction_category_category_key UNIQUE (category);


--
-- Name: account_transaction_category_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY account_transaction_category
    ADD CONSTRAINT account_transaction_category_pkey PRIMARY KEY (id);


--
-- Name: account_transaction_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY account_transaction
    ADD CONSTRAINT account_transaction_pkey PRIMARY KEY (transaction_id);


--
-- Name: account_transaction_type_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY account_transaction_type
    ADD CONSTRAINT account_transaction_type_pkey PRIMARY KEY (id);


--
-- Name: bank_account_type_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY bank_account_type
    ADD CONSTRAINT bank_account_type_pkey PRIMARY KEY (id);


--
-- Name: bank_account_type_type_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY bank_account_type
    ADD CONSTRAINT bank_account_type_type_key UNIQUE (type);


--
-- Name: bank_name_bank_name_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY bank_name
    ADD CONSTRAINT bank_name_bank_name_key UNIQUE (bank_name);


--
-- Name: bank_name_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY bank_name
    ADD CONSTRAINT bank_name_pkey PRIMARY KEY (id);


--
-- Name: client_account_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY client_account
    ADD CONSTRAINT client_account_pkey PRIMARY KEY (client_id);


--
-- Name: client_branch_branch_name_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY client_branch
    ADD CONSTRAINT client_branch_branch_name_key UNIQUE (branch_name);


--
-- Name: client_branch_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY client_branch
    ADD CONSTRAINT client_branch_pkey PRIMARY KEY (branch_id);


--
-- Name: client_client_name_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY client
    ADD CONSTRAINT client_client_name_key UNIQUE (client_name);


--
-- Name: client_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- Name: company_bank_account_account_no_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY company_bank_account
    ADD CONSTRAINT company_bank_account_account_no_key UNIQUE (account_no);


--
-- Name: company_deduction_type_description_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY company_deduction_type
    ADD CONSTRAINT company_deduction_type_description_key UNIQUE (description);


--
-- Name: company_deduction_type_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY company_deduction_type
    ADD CONSTRAINT company_deduction_type_pkey PRIMARY KEY (id);


--
-- Name: department_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY department
    ADD CONSTRAINT department_pkey PRIMARY KEY (dept_no);


--
-- Name: employee_category_category_name_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY employee_category
    ADD CONSTRAINT employee_category_category_name_key UNIQUE (category_name);


--
-- Name: employee_deduction_type_description_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY employee_deduction_type
    ADD CONSTRAINT employee_deduction_type_description_key UNIQUE (description);


--
-- Name: employee_deduction_type_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY employee_deduction_type
    ADD CONSTRAINT employee_deduction_type_pkey PRIMARY KEY (id);


--
-- Name: employee_leave_type_leave_type_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY employee_leave_type
    ADD CONSTRAINT employee_leave_type_leave_type_key UNIQUE (leave_type);


--
-- Name: employee_leave_type_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY employee_leave_type
    ADD CONSTRAINT employee_leave_type_pkey PRIMARY KEY (id);


--
-- Name: employee_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (clockno);


--
-- Name: project_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- Name: project_title_key; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY project
    ADD CONSTRAINT project_title_key UNIQUE (title);


--
-- Name: timesheet_pkey; Type: CONSTRAINT; Schema: payroll_dev; Owner: arossouw; Tablespace: 
--

ALTER TABLE ONLY timesheet
    ADD CONSTRAINT timesheet_pkey PRIMARY KEY (timeid);


--
-- Name: account_transaction_transaction_category_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY account_transaction
    ADD CONSTRAINT account_transaction_transaction_category_fkey FOREIGN KEY (transaction_category) REFERENCES account_transaction_category(id);


--
-- Name: account_transaction_transaction_type_id_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY account_transaction
    ADD CONSTRAINT account_transaction_transaction_type_id_fkey FOREIGN KEY (transaction_type_id) REFERENCES account_transaction_type(id);


--
-- Name: client_account_account_bankname_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY client_account
    ADD CONSTRAINT client_account_account_bankname_fkey FOREIGN KEY (account_bankname) REFERENCES bank_name(id);


--
-- Name: client_account_bank_account_type_id_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY client_account
    ADD CONSTRAINT client_account_bank_account_type_id_fkey FOREIGN KEY (bank_account_type_id) REFERENCES bank_account_type(id);


--
-- Name: client_branch_client_id_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY client_branch
    ADD CONSTRAINT client_branch_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(client_id);


--
-- Name: company_bank_account_bank_account_type_id_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY company_bank_account
    ADD CONSTRAINT company_bank_account_bank_account_type_id_fkey FOREIGN KEY (bank_account_type_id) REFERENCES bank_account_type(id);


--
-- Name: company_deduction_deduction_type_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY company_deduction
    ADD CONSTRAINT company_deduction_deduction_type_fkey FOREIGN KEY (deduction_type) REFERENCES company_deduction_type(id);


--
-- Name: company_deduction_employee_id_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY company_deduction
    ADD CONSTRAINT company_deduction_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employee(clockno);


--
-- Name: employee_bank_account_account_bankname_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_bank_account
    ADD CONSTRAINT employee_bank_account_account_bankname_fkey FOREIGN KEY (account_bankname) REFERENCES bank_name(id);


--
-- Name: employee_bank_account_bank_account_type_id_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_bank_account
    ADD CONSTRAINT employee_bank_account_bank_account_type_id_fkey FOREIGN KEY (bank_account_type_id) REFERENCES bank_account_type(id);


--
-- Name: employee_bank_account_emp_no_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_bank_account
    ADD CONSTRAINT employee_bank_account_emp_no_fkey FOREIGN KEY (emp_no) REFERENCES employee(clockno);


--
-- Name: employee_category_clockno_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_category
    ADD CONSTRAINT employee_category_clockno_fkey FOREIGN KEY (clockno) REFERENCES employee(clockno);


--
-- Name: employee_deduction_clockno_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_deduction
    ADD CONSTRAINT employee_deduction_clockno_fkey FOREIGN KEY (clockno) REFERENCES employee(clockno);


--
-- Name: employee_deduction_deductiontype_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_deduction
    ADD CONSTRAINT employee_deduction_deductiontype_fkey FOREIGN KEY (deductiontype) REFERENCES employee_deduction_type(id);


--
-- Name: employee_dept_clockno_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_dept
    ADD CONSTRAINT employee_dept_clockno_fkey FOREIGN KEY (clockno) REFERENCES employee(clockno);


--
-- Name: employee_dept_dept_no_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_dept
    ADD CONSTRAINT employee_dept_dept_no_fkey FOREIGN KEY (dept_no) REFERENCES department(dept_no);


--
-- Name: employee_leave_approved_by_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_leave
    ADD CONSTRAINT employee_leave_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES employee(clockno);


--
-- Name: employee_leave_leave_type_id_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_leave
    ADD CONSTRAINT employee_leave_leave_type_id_fkey FOREIGN KEY (leave_type_id) REFERENCES employee_leave_type(id);


--
-- Name: employee_salary_emp_no_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employee_salary
    ADD CONSTRAINT employee_salary_emp_no_fkey FOREIGN KEY (emp_no) REFERENCES employee(clockno);


--
-- Name: employment_history_clockno_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY employment_history
    ADD CONSTRAINT employment_history_clockno_fkey FOREIGN KEY (clockno) REFERENCES employee(clockno);


--
-- Name: payroll_employee_id_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY payroll
    ADD CONSTRAINT payroll_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employee(clockno);


--
-- Name: project_client_id_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY project
    ADD CONSTRAINT project_client_id_fkey FOREIGN KEY (client_id) REFERENCES client(client_id);


--
-- Name: project_createdby_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY project
    ADD CONSTRAINT project_createdby_fkey FOREIGN KEY (createdby) REFERENCES employee(clockno);


--
-- Name: project_lastupdatedby_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY project
    ADD CONSTRAINT project_lastupdatedby_fkey FOREIGN KEY (lastupdatedby) REFERENCES employee(clockno);


--
-- Name: timesheet_clockno_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY timesheet
    ADD CONSTRAINT timesheet_clockno_fkey FOREIGN KEY (clockno) REFERENCES employee(clockno);


--
-- Name: timesheet_project_id_fkey; Type: FK CONSTRAINT; Schema: payroll_dev; Owner: arossouw
--

ALTER TABLE ONLY timesheet
    ADD CONSTRAINT timesheet_project_id_fkey FOREIGN KEY (project_id) REFERENCES project(id);


--
-- PostgreSQL database dump complete
--

