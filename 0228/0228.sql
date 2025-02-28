-------- 내장함수 ----------
SELECT ABS(-78), ABS(78) from dual; -- from dual은 오라클함수
use madang;

select custid, round(sum(saleprice)/count(*), -2)
from orders
group by custid;

-- 한글 utf-8(3byte), utf-16(4byte), euc-kr(2byte)
-- 축구의 역사 : 한글 5개 + space 1개 (5x3 +1) = 16
select bookname, length(bookname), char_length(bookname)
from book where bookid in (1,10);

-- adddate
select adddate('2025-02-28', interval 5 day);

-- sysdate() 랑 now() 차이 확인하기
-- insert into orders values(11, 3, 8, 13000, sysdate(), 'aaa');
-- insert into orders values(12, 3, 8, 13000, now(), 'bbb');

-- null에 대한 입장
-- null을 허락 X <= not null with default value
-- null을 허락 O <= null check logic

-- null 연산
select price + 100 from mybook;

-- null 여부 is null, is not null
select * from mybook where price is not null;
select * from mybook where price is null;

-- ifnull() 오라클 nvl
select bookid, price from mybook;

select bookid, ifnull(price, 0) price from mybook;

---------- case when then else -------------
use hr;

-- employee table에서 department_id 가 60, 90인 사원의 salary 합
select department_id, sum(salary)
from employees
where department_id in (60,90)
group by department_id;

-- 1개의 row에 2개의 컬럼으로 표현
select sum(case when department_id=60 then salary else 0 end) sum60,
	   sum(case when department_id=90 then salary else 0 end) sum90 from employees 
where department_id in (60,90);

-- exists
use madang;
 CREATE TABLE customer (
      customer_id int NOT NULL,
      customer_nm varchar(45) NOT NULL,
      PRIMARY KEY (customer_id)
    );
    CREATE TABLE customer_order (
      order_id int NOT NULL,
      customer_id int DEFAULT NULL,
      product_id int DEFAULT NULL,
      order_price int DEFAULT NULL,
      PRIMARY KEY (order_id)
    );
    
insert into customer values ('1', '홍길동');
insert into customer values ('2', '이길동');
insert into customer_order values ('11', '1', '111', '1000');

select * from customer where custid in (select customer_id from customer_order); -- 몇개 안될땐 in이 유리
select * from customer where exists (select customer_id from customer_order);
-- 왼쪽 subquery 의 customer_order가 100건이면 오른쪽 customer 1건에 대해 왼쪽 100과 비교를 하다가 1건이라도 나오면
-- 더이상 따지지 않고 true 처리
select * from customer c where exists (select co.customer_id from customer_order co where c.custid = co.customer_id);

-- not exists
select * from customer where custid not in (select customer_id from customer_order); -- 몇개 안될땐 in이 유리
-- 왼쪽 subquery 의 customer_order가 100건이면 오른쪽 customer 1건에 대해 왼쪽 100과 비교를 하다가 1건이라도 나오면
-- 더이상 따지지 않고 false 처리
select * from customer c where not exists (select customer_id from customer_order co where c.custid = co.customer_id); -- 몇개 안될땐 in이 유리

-- not in not exists with null

-- 1번은 blacklist에 없는데 not in 계산 1!=2 && 1!=null 가 true여야 되는데 null 연산에서 false가 나오면서 1번이 안나옴
-- 즉 not in 쓸때는 null 조심
select * from customer where custid not in (select customer_id from blacklist); -- 0건
-- null 을 제외한 not in 처리가 필요
select * from customer where custid not in (select customer_id from blacklist where customer_id is not null);

select * from customer c where not exists (select b.customer_id from blacklist b where c.custid = b.customer_id);

-- not in : index 이용 X, null에 대한 고려
-- not exists : index 이용 O, null에 대한 고려 X


-- 보고서 쿼리
select o.orderid, o.custid, c.name, b.bookid, b.bookname, o.saleprice, o.orderdate
 from customer c, orders o, book b
where c.custid = o.custid
	and b.bookid = o.bookid;
    
-- View 를 이용한 보고서 (뷰는 쿼리를 저장해놓는거라고 생각)
-- View 를 생성하는 시점에 데이터까지 생성 X, query만 보관
create view VOrders as
select o.orderid, o.custid, c.name, b.bookid, b.bookname, o.saleprice, o.orderdate
 from customer c, orders o, book b
where c.custid = o.custid
	and b.bookid = o.bookid;

-- 은행, 통신 회사 인사팀, 영업팀(전체 데이터가 필요)... 콜센터(제한적인 데이터만 필요)
-- 중요 데이터가 포함된 테이블은 상담에 필요한 일부 컬럼만 콜센터가 사용하도록 한다.
-- 위 경우, 테이블을 콜센터에 직접 노출 X

-- 인덱스
-- 목적 : 빠른 검색
-- 1. 별도의 자료구조를 구성해서 인덱스를 만든다(정렬) 
-- 2. 새로운 데이터가 추가되거나, 기존 데이터가 변경 또는 삭제되면 재구성
-- 3. 결과적으로 검색에서는 이득을 보지만 등록, 수정, 삭제에서는 손해
-- 4. PK, FK 등은 자동으로 인덱스가 생성된다.
-- 5. 거꾸로 특정 컬럼에 인덱스를 추가해도 검색이 개선되지 않고 오히려 느려진다.
--     => 분포도가 낮은 컬럼( 예 : 성별 'M', 'F'이 각각 5백만건씩 있다면? )
--        분포도가 20% 이상이 되면 별로...

-- 아래는 query 실행계획 비교
select * from orders where orderid = 3;
select * from orders where saleprice = 3000;

use test;

-- test 스키마에 jdbc_big 테이블 생성
select count(*) from jdbc_big;
select * from jdbc_big;
-- 100만건 데이터를 이용해서 더 큰 테이블 생성
create table jdbc_big_2 as select * from jdbc_big;
select count(*) from jdbc_big;
-- jdbc_big_2 를 이용해서 jdbc_big 더 크게 insert
insert into jdbc_big(col_2, col_3, col_4) select col_2, col_3, col_4 from jdbc_big_2;

select * from jdbc_big limit 10;
select * from jdbc_big where col_1 = 156651; -- 인덱스가 있어서 바로나옴
select * from jdbc_big where col_2 = '홍길동';

-- Foreign Key(FK)
-- customer, orders, book 테이블에 orders의 custid는 customer, bookid는 book의 key
-- RDB의 핵심인 데이터 무결성을 유지하는 핵심 개념
-- orders 에 customer의 custid를 FK로 지정하는 설정
-- 올바른 테스트를 위해 정상 데이터로 초기화

INSERT INTO Customer VALUES (1, '박지성', '영국 맨체스터', '000-5000-0001');
INSERT INTO Customer VALUES (2, '김연아', '대한민국 서울', '000-6000-0001');  
INSERT INTO Customer VALUES (3, '김연경', '대한민국 경기도', '000-7000-0001');
INSERT INTO Customer VALUES (4, '추신수', '미국 클리블랜드', '000-8000-0001');
INSERT INTO Customer VALUES (5, '박세리', '대한민국 대전',  NULL);
INSERT INTO Orders VALUES (1, 1, 1, 6000, STR_TO_DATE('2024-07-01','%Y-%m-%d'),'1'); 
INSERT INTO Orders VALUES (2, 1, 3, 21000, STR_TO_DATE('2024-07-03','%Y-%m-%d'),'1');
INSERT INTO Orders VALUES (3, 2, 5, 8000, STR_TO_DATE('2024-07-03','%Y-%m-%d'),'1'); 
INSERT INTO Orders VALUES (4, 3, 6, 6000, STR_TO_DATE('2024-07-04','%Y-%m-%d'),'1'); 
INSERT INTO Orders VALUES (5, 4, 7, 20000, STR_TO_DATE('2024-07-05','%Y-%m-%d'),'1');
INSERT INTO Orders VALUES (6, 1, 2, 12000, STR_TO_DATE('2024-07-07','%Y-%m-%d'),'1');
INSERT INTO Orders VALUES (7, 4, 8, 13000, STR_TO_DATE( '2024-07-07','%Y-%m-%d'),'1');
INSERT INTO Orders VALUES (8, 3, 10, 12000, STR_TO_DATE('2024-07-08','%Y-%m-%d'),'1'); 
INSERT INTO Orders VALUES (9, 2, 10, 7000, STR_TO_DATE('2024-07-09','%Y-%m-%d'),'1'); 
INSERT INTO Orders VALUES (10, 3, 8, 13000, STR_TO_DATE('2024-07-10','%Y-%m-%d'),'1');