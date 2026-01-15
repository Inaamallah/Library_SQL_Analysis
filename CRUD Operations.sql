use library_system

-- CRUD OPERATIONS



-- 1: Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

select * from books

insert 
	into books
values 
	('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');




-- 2: Update an Existing Member's Address

select * from members

update members
	set member_address = '141 App St'
where 
	member_id = 'C101';



-- 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

select * from issue_table

delete 
	from issue_table
where 
	issued_id = 'IS121'
	

	
-- 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
	
select * from issue_table
select * from employees


select 	
	i.issued_emp_id as ID, e.emp_name as Name,i. issued_book_name
from employees as e 
inner join issue_table as i on e.emp_id = i.issued_emp_id 
where i.issued_emp_id = 'E101';
	


-- 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.


select * from issue_table
select * from members

select 
	m.member_id,m.member_name, COUNT(i.issued_id) as books_count
from issue_table as i 
inner join members as m on i.issued_member_id = m.member_id
group by m.member_id, m.member_name
having COUNT(i.issued_id) > 1;



