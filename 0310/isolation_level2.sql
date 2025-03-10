-- 동시성 제어 (쓰기, 쓰기)
use madang;
select * from book;

select @@autocommit;
set autocommit = 0;

start transaction;
update book set price = 10000 where bookId = 5;
commit;

-- 데드락 ( Dead Lock )
-- id 1,2 book 에 대하여 테스트
start transaction;
update book set price = 4000 where bookId = 2; --  2번 lock
update book set price = 4000 where bookId = 1; -- 1번 lock

commit;

select * from book;
start transaction;
update book set price = 60000 where bookId = 4; -- 4번 lock
update book set price = 60000 where bookId = 3; -- 3번 lock

commit;

-- 고립수준
select * from users;
start transaction;
-- 쓰기 트랜잭션 unc
update users set age = 21 where id = 1; -- uncommitted 상태

rollback;

start transaction;
-- 쓰기 트랜잭션 unc
update users set age = 30 where id = 1; -- uncommitted 상태
commit;

start transaction;
insert into users values(2, 'LEE GILDONG',21);
commit;