create table employee
(
  emp_no varchar(20) primary key,
  birth_date date NOT NULL,
  firstname varchar(40) NOT NULL,
  surname varchar(40) NOT NULL,
  gender char(1) NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NULL,
  active boolean NOT NULL DEFAULT TRUE
);

insert into employee values 
  ('WG2665','1981-06-09','Arno','Rossouw','M','2008-11-12',NULL,true);


create table client (
  client_id serial primary key,
  client_name varchar(30)
);
insert into client (client_name)
 values ('Workforce');
 

CREATE TYPE work_schedule_type AS ENUM ('Normal Time', 'Over Time', 'Double Time');
create table client_work_hours (
  client_id int not null references client(client_id),
  hourstart time not null,
  hourend time not null,
  schedule_type work_schedule_type
 );
insert into client_work_hours  values
    (1, '08:30','17:00', 'Normal Time'),
    (1, '17:00','23:59', 'Over Time'); 

create table invoice ( 
  total money,
  id serial primary key,
  client_id int not null references client(client_id),
  vat money
);
INSERT INTO invoice (total, vat, client_id)
  values (45.22*2, 10.55*2, 1);
         

create table invoice_item (
  invoice_id int not null references invoice(id),
  amount money,
  vat money,
  qty int not null
);
insert into invoice_item 
   values (1, 45.22, 10.55, 2),
          (1, 93.23, 12.22, 3);
          
update invoice set total = (SELECT sum(amount) from invoice_item where invoice_id=1), vat = (SELECT sum(vat) from invoice_item);
-- update invoice set (total,vat) =  (SELECT sum(amount),sum(vat) from invoice_item where invoice_id=1);


create table timesheet (
  id serial primary key,
  emp_no varchar(20) references employee(emp_no),
  checkin timestamp NOT NULL,
  checkout timestamp NOT NULL,
  description varchar(30),
  client_id int references client(client_id)
);

create table ref_timesheet_invoice (
  invoice_id INT NOT NULL references invoice(id),
  timesheet_id INT NOT NULL references timesheet(id)
);
  

insert into timesheet (emp_no, checkin, checkout, description, client_id)
   values ('WG2665', now(), now() + INTERVAL '8 hour', 'Normal Time', 1),
          ('WG2665', now() + INTERVAL '9 hour', now() + INTERVAL '10 hour', 'Overtime', 1);

  
