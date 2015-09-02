create table employee (
   clockno int not null primary key,
   birth_date date,
   firstname varchar(40),
   lastname  varchar(40),
   gender   char(1),
   hire_date DATE NOT NULL,
   active boolean NOT NULL DEFAULT TRUE
);

create table employee_category (
    clockno int not null references employee(clockno),
	category_name varchar(30) NOT NULL,
	UNIQUE(category_name)
);

create table employment_history (
    clockno int not null references employee(clockno),
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	title varchar(35) NOT NULL,
	CHECK (from_date < to_date)
);

create table employee_leave_type (
     id serial primary key,
     leave_type varchar(15) NOT NULL,
	 UNIQUE(leave_type)
);

create table employee_leave (
	approved_by int not null references employee(clockno),
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
	leave_type_id int references employee_leave_type(id) NOT NULL,
	CHECK (from_date < to_date)
);

create table employee_deduction_type (
	id serial primary key,
    description varchar(35) NOT NULL,
	UNIQUE(description)
);
	

create table employee_deduction (
	clockno int not null references employee(clockno),
	deductiontype int not null references employee_deduction_type(id),
	amount real NOT NULL,
	deductiondate DATE NOT NULL
);

create table department (
    dept_no serial primary key,
    dept_name varchar(25) NOT NULL
);

create table employee_dept (
     clockno int not null references employee(clockno) NOT NULL, 
     dept_no int references department(dept_no) NOT NULL
);


create table bank_account_type (
   id serial primary key,
   type varchar(20) NOT NULL,
   UNIQUE(type)
);

create table bank_name (
   id serial primary key,
   bank_name varchar(20) NOT NULL,
   UNIQUE(bank_name)
);

create table employee_bank_account (
	emp_no int not null references employee(clockno) NOT NULL,
	bank_account_type_id int references bank_account_type(id) NOT NULL,
	account_no varchar(20) NOT NULL,
	account_branch varchar(20) NOT NULL,
	account_bankname int references bank_name(id) NOT NULL
);

create table client_account (
   client_id int primary key,
   bank_account_type_id int references bank_account_type(id) NOT NULL,
   account_no varchar(20) NOT NULL,
   account_branch varchar(30) NOT NULL,
   account_bankname int references bank_name(id) NOT NULL
);

create table client (
     client_id serial primary key,
     client_name varchar(30) NOT NULL,
	UNIQUE(client_name)
);


create table client_branch (
   client_id int references client(client_id) NOT NULL,
   branch_id serial primary key,
   address TEXT NOT NULL,
   branch_name varchar(40) NOT NULL,
   phone varchar(15),
   email varchar(35),
   UNIQUE(branch_name)
);

create table project (
	id serial primary key,
	client_id int not null references client(client_id),
	title varchar(30) NOT NULL,
	description varchar(45) NOT NULL,
	startdate timestamp NOT NULL,
	enddate	  timestamp NULL,
	createdby int not null references employee(clockno),
	lastupdatedby int not null references employee(clockno),
	UNIQUE(title)
);

create table timesheet (
	timeid serial primary key,
	clockno int not null references employee(clockno) NOT NULL,
	checkin timestamp NOT NULL,
	checkout timestamp NOT NULL,
	description varchar(30) NOT NULL,
	project_id int references project(id) NOT NULL,
	CHECK (checkout > checkin)
);
	

create table company_bank_account (
   bank_account_type_id int references bank_account_type(id) NOT NULL,
   account_no   varchar(30) NOT NULL,
   account_branch varchar(30) NOT NULL,
   account_bank varchar(30) NOT NULL,
  UNIQUE(account_no)
);

create table payroll (
    payroll_id int not null,
    employee_id int not null references employee(clockno),
    hoursworked  int not null,
    grosspay     real not null,
    deductions   real not null,
    netpay	real not null
);

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
