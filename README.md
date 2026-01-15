# Library Analysis using SQL

## Project Overview 

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
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


```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert 
	into books
values 
	('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');


```
**Task 2: Update an Existing Member's Address**

```sql
update members
	set member_address = '141 App St'
where 
	member_id = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
delete 
	from issue_table
where 
	issued_id = 'IS121'
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select 	
	i.issued_emp_id as ID, e.emp_name as Name,i. issued_book_name
from employees as e 
inner join issue_table as i on e.emp_id = i.issued_emp_id 
where i.issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select 
	m.member_id,m.member_name, COUNT(i.issued_id) as books_count
from issue_table as i 
inner join members as m on i.issued_member_id = m.member_id
group by m.member_id, m.member_name
having COUNT(i.issued_id) > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table Book_Counts
as
select b.isbn, b.book_title,count(i.issued_book_isbn) as Counts
from books as b
inner join issue_table as i on b.isbn = i.issued_book_isbn
group by 1,2

select * from Book_Counts

```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
select 
	book_title
from books
where category = 'Children'
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select 
	b.category, sum(b.rental_price), count(i.issued_id)
from books as b
inner join issue_table as i on b.isbn = i.issued_book_isbn
group by 1
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
select
	*
from members
where 
	DATEDIFF(CURRENT_DATE(),reg_date) <= 730;


-- OR Second Approach

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE() - INTERVAL 2 year;
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select 
	e.emp_id, e.emp_name,  e2.emp_name as manager_name, b.*
from employees as e
inner join branch as b on e.branch_id = b.branch_id
inner join employees as e2 on b.manager_id = e2.emp_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
create table high_rental_price_books
as 
	select * from books
	where rental_price >= 7;

select * from high_rental_price_books
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
select 
	i.issued_book_name, i.issued_member_id, i.issued_date
from issue_table as i
left join return_status as r on i.issued_id = r.issued_id
where r.issued_id is null
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
select 
	m.member_id, m.member_name, i.issued_book_name, i.issued_date, CURRENT_DATE() - i.issued_date as Over_Due_Days
from members as m
inner join issue_table as i on m.member_id = i.issued_member_id
left join return_status as r on i.issued_id = r.issued_id
where 
	r.return_id is null
	and 
	(CURRENT_DATE() - i.issued_date) > 30
order by 2
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

-- CREATING TRIGGER
DELIMITER $$
create trigger status_change 
after insert on return_status 
for each row 
	begin 
		update books 
			set status = 'yes' 
		where isbn = (
			select 
				issued_book_isbn 
			from issue_table 
			where (
				issued_id = new.issued_id
			)
			
		);
	end $$
DELIMITER ;

show triggers

-- INSERTING VALUE
insert into return_status 
values 
	('RS119','IS134','2026-01-14');


-- EXECUTION
select 
	i.issued_id, b.isbn, b.book_title,b.status
from books as b
inner join issue_table as i on b.isbn = i.issued_book_isbn
where b.isbn= '978-0-375-41398-8'
```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
drop table if exists performance_report;
create table performance_report 
as
(
	select 
		br.*,count(i.issued_id) as Total_Books_Issued, count(r.return_id) as Total_Books_Returned, sum(b.rental_price) as Rental_Price
	from issue_table as i
	join employees as e on i.issued_emp_id = e.emp_id
	join branch as br on e.branch_id = br.branch_id 
	join books as b on i.issued_book_isbn = b.isbn
	left join return_status as r on i.issued_id = r.issued_id
	group by 1
		
)

select * from performance_report
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

drop table if exists active_members
create table active_members
as 
(
	select 
		m.member_id, m.member_name, 
		GROUP_CONCAT(i.issued_book_name SEPARATOR ',') as Books, 
		count(i.issued_id) as Total_Books_Issued
	from members as m
	join issue_table as i on m.member_id = i.issued_member_id
	where 
		datediff(current_date(),i.issued_date) <= 60 
	group by 1,2
	having 
		count(i.issued_id) >= 1

)

select * from active_members

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
with ranked
as (
	select 
		distinct e.emp_id, e.emp_name, br.branch_id,count(i.issued_book_isbn) as Total_Books_Processed,
		dense_rank() over(order by count(i.issued_book_isbn)) as Ranking
	from employees as e
	join issue_table as i on e.emp_id = i.issued_emp_id
	join branch as br on e.branch_id = br.branch_id
	group by 1,2
	order by Ranking 

)
select * 
from ranked 
order by Ranking desc
limit 3
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

```sql
select 
	m.member_id,m.member_name, GROUP_CONCAT(i.issued_book_name separator ','), count(i.issued_id) as Damaged_Books, b.status as Status
from books as b
join issue_table as i on b.isbn = i.issued_book_isbn
join members as m on i.issued_member_id = m.member_id
where 
	b.status = 'Damaged'
group by 1
having 
	count(i.issued_id) >= 2;
```

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

create table members_books
as 
(
	select 
		m.member_id,m.member_name, 
		sum(datediff(current_date(),i.issued_date)) as Overdue_Days,
		sum((datediff(current_date(),i.issued_date) - 30) * 0.5) as Total_Fine,
		count(i.issued_id) as Number_of_Books
	from members as m
	join issue_table as i on m.member_id = i.issued_member_id 
	left join return_status as r on i.issued_id = r.issued_id 
	where 
		datediff(current_date(),i.issued_date) > 30 
		and 
		r.return_id is null
	group by 1,2
	order by 3 desc
	
		
)

select * from members_books

```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql

drop procedure if exists updating_status;
delimiter $$
	create procedure updating_status(in i_id varchar(100), in i_mem_id varchar(100),in i_emp_id varchar(100), in b_isbn varchar(100))
	begin 
		
		declare b_status varchar(10);
		declare b_title varchar(100);
		
		
		select 
			status into b_status 
		from books 
		where isbn = b_isbn;


		if b_status = 'yes' 
			then 
				select 
					book_title into b_title 
				from books 
				where isbn = b_isbn;
				
				insert into issue_table (issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id)	
				values 
					(i_id,i_mem_id,b_title,CURRENT_DATE(),b_isbn,i_emp_id);
			
			
			
				update books 
				set status = 'no' 
				where isbn = b_isbn;
		elseif b_status = 'no' 
			then 
				select 'Book is currently not available' as Message;
		else 
			select 'ISBN not found' as Message;
		end if;
	end $$ 
delimiter ;
	


call updating_status('IS141','C119','E111','978-0-06-112008-4');

```

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## Author - Inaamallah Sarfraz

This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis, connect with me through the following channels:

- **LinkedIn**: [Connect with me professionally](www.linkedin.com/in/inaamallah)

Thank you for your interest in this project!
