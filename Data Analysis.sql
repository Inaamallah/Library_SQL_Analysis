use library_system

-- DATA ANALYSIS

-- 7: Retrieve All Books in a Specific Category:

select 
	book_title
from books
where category = 'Children'


-- 8: Find Total Rental Income by Category:

select * from books
select * from issue_table


select 
	b.category, sum(b.rental_price), count(i.issued_id)
from books as b
inner join issue_table as i on b.isbn = i.issued_book_isbn
group by 1

	
-- 9: List Members Who Registered in the Last 2 Year:

select * from members

select
	*
from members
where 
	DATEDIFF(CURRENT_DATE(),reg_date) <= 730;


-- OR Second Approach

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE() - INTERVAL 2 year;


-- 10: List Employees with Their Branch Manager's Name and their branch details:

select * from employees
select * from branch


select 
	e.emp_id, e.emp_name,  e2.emp_name as manager_name, b.*
from employees as e
inner join branch as b on e.branch_id = b.branch_id
inner join employees as e2 on b.manager_id = e2.emp_id



-- 11: Create a Table of Books with Rental Price Above a Certain Threshold:

create table high_rental_price_books
as 
	select * from books
	where rental_price >= 7;

select * from high_rental_price_books



-- 12: Retrieve the List of Books Not Yet Returned
select * from return_status


select 
	i.issued_book_name, i.issued_member_id, i.issued_date
from issue_table as i
left join return_status as r on i.issued_id = r.issued_id
where r.issued_id is null






	
	
	
	
	
	
