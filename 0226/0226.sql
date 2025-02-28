select * from customer; -- 5 건
select * from orders; -- 10 건
select * from customer, orders;  -- 5 x 10 건
select * from customer, orders where customer.custid = orders.custid;  -- 위 카디젼프로덕트로부터 10 건 추출
select customer.custid, customer.name, orders.saleprice, orders.orderdate -- 원하는 테이블의 컬럼을 선택
  from customer, orders where customer.custid = orders.custid;  
 -- 두 테이블에 중복되는 컬럼은 table 명을 생략 X (custid)
 -- 한 테이블에만 있는 컬럼은 table 명을 생략 O (name, saleprice)
 -- 테이블명을 모두 명시하는 것이 가독성이 좋다.
select customer.custid, name, saleprice, orderdate
  from customer, orders where customer.custid = orders.custid;    
-- join 경우, 테이블 alias 를 사용 권장 (단, alias 를 사용할 경우 컬럼명에도 alias 를 함께 사용)  
select c.custid, c.name, o.saleprice, o.orderdate
  from customer c, orders o where c.custid = o.custid;  
-- order by  추가  
select c.custid, c.name, o.saleprice, o.orderdate
  from customer c, orders o where c.custid = o.custid
 order by c.custid;
-- sum (고객이름 <= 사실상 고객별 ... 처리 )
select c.name, sum(o.saleprice)
  from customer c, orders o where c.custid = o.custid
  group by  c.name
 order by c.name; 
-- 고객별 sum 을 구하는 데 동명이인이 있으면?
-- 고객의 구분자(식별자)인 Primary Key 로 group by  필요. 
select c.name, sum(o.saleprice)
  from customer c, orders o where c.custid = o.custid
  group by  c.custid -- Key 는 group by  에 올 수 있다.
 order by c.name;  
 
 
-- 실무  SQL 과 지금 SQL ???
-- 1. 하나의 SQL 에서 처리하는 테이블 수가 더 많다. (보통 5개 정도) 
-- 2. 테이블 당 데이터 건수가 어~~~~엄첨 많다. ( 1억건 이상 )
-- 3. 작성하는 SQL 이 훠~~~얼씬 복잡하다.
-- 3개의 테이블
select * from customer; -- 5 건
select * from book; -- 10건
select * from orders; -- 10 건
select * from customer, book, orders;  -- 5 x 10 x 10 건
select * from customer, book, orders 
where customer.custid = orders.custid
   and book.bookid = orders.bookid;  --  orders 기준 customer, book 의 key 와 join 조건
-- 테이블 alias, 원하는 컬럼만    
select c.name, c.address,  b.bookname, o.orderdate
  from customer c, book b, orders o
where c.custid = o.custid
   and b.bookid = o.bookid;  --  orders 기준 customer, book 의 key 와 join 조건   
-- 각 테이블 별 조건 추가    
select c.name, c.address,  b.bookname, o.orderdate -- * 로 카티젼프로덕트를 만들고 난 후 원하는 컬럼만 선택
  from customer c, book b, orders o
where c.custid = o.custid
   and b.bookid = o.bookid
   and c.name like '김%' -- 고객이름이 김 으로 시작 ( select 항목 포함 )
   and o.saleprice < 10000; -- select 항목 포함 X
   
-- 표준 SQL JOIN ( ANSI SQL JOIN )   
select c.custid, c.name, o.saleprice, o.orderdate
  from customer c, orders o
where c.custid = o.custid;  
-- 위 쿼리를 ansi sql join  으로 변경하면
select c.custid, c.name, o.saleprice, o.orderdate
  from customer c inner join orders o on c.custid = o.custid;
   
select c.name, c.address,  b.bookname, o.orderdate -- * 로 카티젼프로덕트를 만들고 난 후 원하는 컬럼만 선택
  from customer c, book b, orders o
where c.custid = o.custid
   and b.bookid = o.bookid
   and c.name like '김%' -- 고객이름이 김 으로 시작 ( select 항목 포함 )
   and o.saleprice < 10000; -- select 항목 포함 X
-- 위 쿼리를 ansi sql join  으로 변경하면   
-- inner  를 생략하면 기본 join 이 inner join
select c.name, c.address,  b.bookname, o.orderdate -- * 로 카티젼프로덕트를 만들고 난 후 원하는 컬럼만 선택
  from orders o inner join customer c on o.custid = c.custid
                    inner join book b on o.bookid = b.bookid
where c.name like '김%' -- 고객이름이 김 으로 시작 ( select 항목 포함 )
   and o.saleprice < 10000; -- select 항목 포함 X
-- outer join  
-- 모든 고객 대상으로  고객 이름, 구매금액을 구하라 ( 단, 구매하지 않은 고객도 포함 )
select c.name, o.saleprice
  from customer c left outer join orders o on c.custid = o.custid;
-- 모든 도서 대상으로  도서 이름, 판매금액을 구하라 ( 단, 판매하지 않은 도서도 포함 )   
select b.bookid, b.bookname, o.saleprice
   from book b left join orders o on b.bookid = o.bookid;
-- self join 
-- hr db employee 테이블
-- first_name = 'Den' and last_name='Raphaely' 인 사원이 관리하는 부하 사원의 이름, 직급
select *
  from employees staff, employees manager
 where staff.manager_id = manager.employee_id
   and manager.first_name = 'Den' 
   and manager.last_name='Raphaely';