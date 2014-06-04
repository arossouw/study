BEGIN;
create table employees (
   clockno varchar(20) primary key,
   birth_date date,
   firstname varchar(40),
   lastname  varchar(40),
   gender   char(1),
   hire_date date NOT NULL,
   active boolean NOT NULL DEFAULT TRUE
);

create table hr_leave_types (
     id serial primary key,
     leave_name varchar(15)
);

create table hr_leave (
	approved_by varchar(20) references employees(clockno),
        from_date DATE,
        to_date DATE,
	leave_type_id int references hr_leave_types(id),
	taken int NOT NULL,
	annual_leave_days int NOT NULL
);

create table departments (
    dept_no serial primary key,
    dept_name varchar(25)
);

create table employee_dept (
     clockno varchar(20) references employees(clockno), 
     dept_no int references departments(dept_no),
     from_date DATE,
     to_date DATE
);

create table salary (
   clockno varchar(20) references employees(clockno),
   salary  real CHECK (salary > 0),
   from_date DATE,
   to_date DATE
);

create table job_titles (
    clockno varchar(20) references employees(clockno),
    title  varchar(35),
    from_date DATE,
    to_date DATE
);

create table account_types (
   id serial primary key,
   type varchar(20),
   UNIQUE(type)
);

create table client_accounts (
   client_id int primary key,
   account_type_id int references account_types(id),
   account_no varchar(20),
   account_branch varchar(30),
   account_bank varchar(20)
);

create table invoices (
    id int primary key,
    client_id int references client_accounts(client_id),
    description varchar(35),
    type varchar(5),    -- NT = Normal Time / OT = OverTime / DT = Double Time
    invoice_date DATE
);

create table invoice_item (
    rate  real,
    hours  int,
    amount real,    
    invoice_id int references invoices(id),
    date DATE,
    CHECK (rate > 0 and hours > 0 and amount > 0)
);


create table client_details (
   name varchar(40) primary key,
   address TEXT,
   city TEXT,
   phone varchar(15),
   email varchar(35) 
);

create table company_bank_account (
   account_type_id int references account_types(id),
   account_no   varchar(30),
   account_branch varchar(30),
   account_bank varchar(30),
  UNIQUE(account_no)
);


create table account_transaction_types (
   id  serial primary key,
   type  char(3)
);

create table account_transactions (
   transaction_id int primary key,
   from_account_id int,
   to_account_id  int,
   invoice_no  int references invoices(id),
   transaction_type_id int references account_transaction_types(id)
);
COMMIT;
