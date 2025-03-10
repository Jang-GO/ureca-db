-- 동시성 제어 (쓰기, 쓰기)
-- Lock 은 row 단위로 처리된다.
use madang;
select * from book;

select @@autocommit;
set autocommit = 0;

start transaction;
update book set price = 2000 where bookId = 1;
commit;

-- 데드락 ( Dead Lock )
-- id 1,2 book 에 대하여 테스트
start transaction;
update book set price = 5000 where bookId = 1; -- 1번 lock
update book set price = 5000 where bookId = 2; -- 2번 lock

commit;

select * from book;
start transaction;
update book set price = 50000 where bookId = 3; -- 3번 lock
update book set price = 50000 where bookId = 4; -- 4번 lock

commit;