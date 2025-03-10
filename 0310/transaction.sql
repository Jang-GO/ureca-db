set autocommit = 0;
select @@autocommit;

-- 여러 insert, update, delete 같은 DB에 변화를 주는 쿼리 여러개 실행
-- 단 쿼리 들 전체가 하나의 작업단위 (transaction)로 처리

-- customer trucate( truncate는 롤백 불가)
select * from customer;

start transaction;

insert into customer values(1, '홍길동');
insert into customer values(2, '이길동');
insert into customer values(3, '삼길동');

commit; -- 트랜잭션 완료
rollback; -- 트랜잭션 취소

-- 복잡하고 긴 transaction 작업 수행 (5-6시간 걸리는 작업)
-- 개발계 서버에서 코드 작성
-- A,B,C 작업 완료 3시간 걸린다는 가정
-- A,B,C 는 완성, D 개발중... A,B,C 는 완성된 상태로 
start transaction;

-- A 테이블 변화
-- B 테이블 조회, 결과값에 따라 다르게 처리(PL-SQL)
-- C 테이블 변화
-- D 테이블 변화
-- E 테이블 조회
-- ...

-- 홍길동, 이길동 insert를 위  A,B,C로 가정, 삼길동 insert를 D 가정
insert into customer values(1, '홍길동');
insert into customer values(2, '이길동');

savepoint s1; -- 여기로 롤백 가능

insert into customer values(3, '삼길동');

commit; -- 트랜잭션 완료
rollback to s1; -- 트랜잭션 취소

truncate customer;