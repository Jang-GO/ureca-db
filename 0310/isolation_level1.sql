-- 고립수준
-- 한 트랜잭션은 읽기, 다른 트랜잭션은 쓰기를 진행
-- 읽는 트랜잭션이 쓰는 트랜잭션의 변화를 어떻게 대응할 것인가 하는 정책에 따라 다른 결과를 보여준다.

-- set transaction isolation level ____; 
/*
____ 에 올 수 있는 경우
* read uncommited : 쓰기 트랜잭션의 변화가 commit 되지 않아도 읽는다.
	* 읽기 트랜잭션에서 commit 되지 않은 데이터를 읽은 후 쓰기 트랜잭션에서 rollback하면 잘못된 데이터를 읽게 된다. (dirty read)
* read commited : 쓰기 트랜잭션의 변화가 commit 되어야만 읽는다.
	* 읽기 트랜잭션에서 이전에 commit된 데이터를 읽은 후 쓰기 트랜잭션에서 변경 commit 하면 이전에 읽은 데이터와 달라진다( non-repeatable read ) 
	*  읽기 트랜잭션에서 이전에 commit된 데이터를 읽은 후 (복수개가 될 수 있는) 쓰기 트랜잭션에서 변경 commit 하면 이전에 읽은 데이터와 달라진다( phantom read ) 

* repeatable read
	* 읽기 트랜잭션에서 이전에 commit된 데이터를 읽은 후 쓰기 트랜잭션에서 변경 commit 해도 이전에 읽은 데이터와 동일하게 읽는다 
*/

CREATE TABLE Users
( id INTEGER,
  name  VARCHAR(20),
  age   INTEGER);
INSERT INTO Users VALUES (1, 'HONG GILDONG', 30);

select * from users;

set transaction isolation level read uncommitted;
start transaction;
select * from users where id = 1; -- 최초 30
select * from users where id = 1; -- 변경 후 21
commit;

set transaction isolation level read committed;
start transaction;
select * from users where id = 1; -- 최초 30
select * from users where id = 1; -- 쓰기 트랜잭션 commit된 21
commit;

set transaction isolation level read committed;
start transaction;
select * from users where age between 10 and 30; -- 첨엔 홍길동만
select * from users where age between 10 and 30; -- 두번째엔 홍길동이랑 커밋된 이길동도 같이보임
commit;

set transaction isolation level repeatable read;
start transaction;
select * from users where age between 10 and 30; -- 첨엔 홍길동만
select * from users where age between 10 and 30; -- 두번째엔 repeatable read여서 최초 홍길동만 보임
commit;
