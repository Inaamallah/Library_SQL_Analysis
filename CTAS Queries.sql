use library_system

-- CTAS QUERIES

-- 6: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

select * from books
select * from issue_table


create table Book_Counts
as
select b.isbn, b.book_title,count(i.issued_book_isbn) as Counts
from books as b
inner join issue_table as i on b.isbn = i.issued_book_isbn
group by 1,2

select * from Book_Counts


