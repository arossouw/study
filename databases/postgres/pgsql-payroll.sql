BEGIN;

create table employee (
   clockno varchar(20) primary key,
   birth_date date,
   firstname varchar(40),
   lastname  varchar(40),
   gender   char(1),
   from_date DATE NOT NULL,
   to_date   DATE NULL,
   active boolean NOT NULL DEFAULT TRUE
);

create table hourly_employee (
	rate real,
	clockno varchar(20) references employee(clockno)
);

create table commision_employee (
	rate real,
	commision_percent int
);

create table hr_leave_type (
     id serial primary key,
     leave_name varchar(15)
);

create table hr_leave (
	approved_by varchar(20) references employee(clockno),
        from_date DATE,
        to_date DATE,
	leave_type_id int references hr_leave_type(id),
	taken int NOT NULL,
	annual_leave_days int NOT NULL
);

create table hr_sickday (
	sickid serial primary key,
	clockno varchar(20) references employee(clockno),
	datesick DATE,
	payment real
);

create table hr_deduction (
	deductid serial primary key,
	clockno varchar(20) references employee(clockno),
	deductiontype varchar(20),
	amount real,
	note TEXT
);


create table department (
    dept_no serial primary key,
    dept_name varchar(25)
);

create table employee_dept (
     clockno varchar(20) references employee(clockno), 
     dept_no int references department(dept_no),
     from_date DATE,
     to_date DATE
);

create table salary (
   clockno varchar(20) references employee(clockno),
   salary  real CHECK (salary > 0),
   from_date DATE,
   to_date DATE
);

create table jobtitle (
    clockno varchar(20) references employee(clockno),
    title  varchar(35)
);

create table account_type (
   id serial primary key,
   type varchar(20),
   UNIQUE(type)
);

create table client_account (
   client_id int primary key,
   account_type_id int references account_type(id),
   account_no varchar(20),
   account_branch varchar(30),
   account_bank varchar(20)
);


/*
create table invoice (
    id int primary key,
    client_id int references client_account(client_id),
    description varchar(35),
    type varchar(5),    -- NT = Normal Time / OT = OverTime / DT = Double Time
    invoice_date DATE
);

create table invoice_item (
    rate  real,
    hours  int,
    amount real,    
    invoice_id int references invoice(id),
    date DATE,
    CHECK (rate > 0 and hours > 0 and amount > 0)
);
*/


create table client (
     client_id serial primary key,
     client_name varchar(30)
);


create table client_branch (
   client_id int references client(client_id),
   branch_id serial primary key,
   address TEXT,
   branch_name varchar(40),
   phone varchar(15),
   email varchar(35),
   UNIQUE(branch_name)
);

create table timesheet (
	timeid serial primary key,
	clockno varchar(20) references employee(clockno),
	checkin timestamp,
	checkout timestamp,
	hours	real,
	description varchar(30),
	client_id int references client(client_id)
);
	

create table company_bank_account (
   account_type_id int references account_type(id),
   account_no   varchar(30),
   account_branch varchar(30),
   account_bank varchar(30),
  UNIQUE(account_no)
);

create table payroll (
    payroll_id serial primary key,
    employee_id varchar(20) references employee(clockno),
    hoursworked  int,
    grosspay     real,
    deductions   real,
    netpay	real
);
/*

create table account_transaction_type (
   id  serial primary key,
   type  char(3)   -- CR or DR  CR==Credit, DR==Debit
);

create table account_transaction_category (
    id serial primary key,
    category varchar(30), -- payroll, services rendered etc.
   UNIQUE(category)
);

create table account_transaction (
   transaction_id int primary key,
   from_account_id int,
   to_account_id  int,
   transaction_category  int references account_transaction_category(id),
   transaction_type_id int references account_transaction_type(id)
);
*/
COMMIT;
