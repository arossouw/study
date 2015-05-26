create table employee (
   clockno int not null primary key,
   birth_date date,
   firstname varchar(40),
   lastname  varchar(40),
   gender   char(1),
   hire_date DATE NOT NULL,
   active boolean NOT NULL DEFAULT TRUE
);

create table job_history (
    clockno int not null references employee(clockno),
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	title varchar(35),
	CHECK (from_date < to_date)
);

create table hr_leave_type (
     id serial primary key,
     leave_name varchar(15)
);

create table hr_leave (
	approved_by int not null references employee(clockno),
    from_date DATE,
    to_date DATE,
	leave_type_id int references hr_leave_type(id),
	taken int NOT NULL,
	days_left int NOT NULL,
	CHECK (from_date < to_date)
);

create table hr_deduction (
	deductid serial primary key,
	clockno int not null references employee(clockno),
	deductiontype varchar(20),
	amount real,
	note TEXT
);


create table department (
    dept_no serial primary key,
    dept_name varchar(25)
);

create table employee_dept (
     clockno int not null references employee(clockno), 
     dept_no int references department(dept_no)
);

create table job_salary (
	title varchar(20) not null,
	minimum money,
	maximum money,
    CHECK (maximum > minimum),
	UNIQUE(title)	
);


create table bank_account_type (
   id serial primary key,
   type varchar(20),
   UNIQUE(type)
);

create table client_account (
   client_id int primary key,
   bank_account_type_id int references bank_account_type(id),
   account_no varchar(20),
   account_branch varchar(30),
   account_bank varchar(20)
);

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
	clockno int not null references employee(clockno),
	checkin timestamp,
	checkout timestamp,
	hours	real,
	description varchar(30),
	client_id int references client(client_id),
	CHECK (checkout > checkin)
);
	

create table company_bank_account (
   bank_account_type_id int references bank_account_type(id),
   account_no   varchar(30),
   account_branch varchar(30),
   account_bank varchar(30),
  UNIQUE(account_no)
);

create table payroll (
    payroll_id serial primary key,
    employee_id int not null references employee(clockno),
    hoursworked  int,
    grosspay     real,
    deductions   real,
    netpay	real
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
