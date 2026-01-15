create database library_system

use library_system


-- CREATING BRANCH TABLE

drop table if exists branch;
create table branch (
	branch_id varchar(10) primary key,
	manager_id varchar(10),
	branch_address varchar(50),
	contact_no int

)

-- CREATING EMPLOYEE TABLE

drop table if exists employees;
create table employees(
	emp_id varchar(10) primary key,
	emp_name varchar(20),
	position varchar(10),
	salary int,
	branch_id  varchar(10) 
);


-- CREATING BOOKS TABLE

drop table if exists books;
create table books(
	isbn varchar(25) primary key,
	book_title varchar(100),
	category varchar(50),
	rental_price float,
	status varchar(10),
	author varchar(50),
	publisher varchar(50)
)


-- CREATING MEMBERS TABLE

drop table if exists members;
create table members(
	member_id varchar(15) primary key,
	member_name varchar(50),
	member_address varchar(100),
	reg_date date
)

-- CREATING ISSUE STATUS TABLE

drop table if exists issue_table;
create table issue_table(
	issued_id varchar(20) primary key,
	issued_member_id varchar(15),
	issued_book_name varchar(50),
	issued_date date,
	issued_book_isbn varchar(20),
	issued_emp_id varchar(20)
)


-- CREATING RETURN STATUS TABLE

drop table if exists return_status;
create table return_status(
	return_id varchar(20) primary key,
	issued_id varchar(20),
	return_date date
)


-- CREATING CONNECTIONS

alter table employees
add constraint fk_branch_id
	foreign key (branch_id) references branch(branch_id)

alter table issue_table
add constraint fk_book_isbn
	foreign key (issued_book_isbn) references books(isbn),
add constraint fk_emp_id
	foreign key (issued_emp_id) references employees(emp_id),
add constraint fk_mem_id
	foreign key (issued_member_id) references members(member_id);

alter table return_status
add constraint fk_issued_id
	foreign key (issued_id) references issue_table(issued_id);


-- MAKING SOME CORRECTIONS

alter table branch
modify contact_no varchar(50)


alter table issue_table
modify issued_book_name varchar(100)








