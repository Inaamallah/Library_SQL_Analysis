use library_system


select * from books
select * from branch 
select * from employees 
select * from issue_table 
select * from members 
select * from return_status

-- ADVANCED SQL QUERIES

-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

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






	
-- Write a query to update the status of books in the books table to "Yes"
-- when they are returned (based on entries in the return_status table).


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


-- WATCHING EXECUTION
select 
	i.issued_id, b.isbn, b.book_title,b.status
from books as b
inner join issue_table as i on b.isbn = i.issued_book_isbn
where b.isbn= '978-0-375-41398-8'







-- Create a query that generates a performance report for each branch,
-- showing the number of books issued, the number of books returned, 
-- and the total revenue generated from book rentals.

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











-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
-- containing members who have issued at least one book in the last 2 months.

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

















-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.


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
	








-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
-- Display the member name, book title, and the number of times they've issued damaged books.


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












-- Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
-- The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
-- The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines



-- member, issued
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




















/* Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: 
 * The stored procedure should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). 
 * If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
 * If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

 */

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





















