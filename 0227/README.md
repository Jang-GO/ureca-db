# 0227
### LIMIT, OFFSET
* `LIMIT` : 반환할 튜플의 최대 개수를 지정
* `OFFSET` : 건너뛸 튜플의 개수를 지정하는 키워드(페이징)
```sql
select * from book limit 3 offset 2;
select * from book limit 3, 2; -- offset 생략 주의!
```
> * `OFFSET` 키워드 생략은 MySQL에서만 지원되는 문법이다.
> * 이때, `LIMIT a,b`는 `a`가 OFFSET값이고 `b`가 LIMIT 값이다.
> * 명시적으로 OFFSET 키워드를 작성하여 혼란을 피하자.

### 스키마와 테이블의 대소문자 구분
* 데이터베이스에서 테이블 및 컬럼 이름이 대소문자를 구분할지 여부는 설정에 따라 다름
* `BINARY(column)` 을 사용하면 컬럼 값을 이진 문자열로 비교(대소문자 구분 가능)
```sql
SELECT * FROM book WHERE publisher = 'pearson'; -- 3건
SELECT * FROM book WHERE BINARY(publisher) = 'pearson'; -- 1건
```

## 서브쿼리
* 하나의 SQL문 안에 다른 SQL문이 중첩된 쿼리
* 주로 메인 쿼리의 조건에 따라 서브 쿼리의 결과를 가져와서 메인 쿼리에 사용하는 용도

### 서브쿼리 사용 위치에 따른 구분
1. 스칼라 서브쿼리(Scalar Subquery)
* `SELECT` 절에서 사용되며, 반드시 단일 행 결과만 반환해야 함
* select 된 row 건건 별로 서브쿼리를 수행하므로 성능에 주의
```sql
SELECT bookid, bookname, (SELECT AVG(price) FROM book) AS avg_price
FROM book;
```

2. 인라인 뷰 서브쿼리(Inline-view Subquery)
* `FROM`절에서 사용되며, 서브쿼리를 가상의 테이블 처럼 활용
```
SELECT * FROM (SELECT bookid, bookname, price FROM book WHERE price > 10000) AS expensive_books;
```

3. 네스티드 서브쿼리(Nested Subquery)
* `WHERE`, `HAVING`, `JOIN` 등 다양한 절에서 조건으로 사용된다.
* 단일 행, 다중 행, 다중 열을 반환할 수 있으며, 적절한 연산자(=, IN, EXISTS 등)를 사용해야 한다.
```
select name  from customer where custid in ( select custid from orders );   -- sub : 10 건 
select name  from customer where custid in ( select distinct custid from orders ); -- sub : 4 건
```

### 상관 서브쿼리
* 메인 쿼리의 각 행마다 서브쿼리가 실행됨
* 서브쿼리가 본 쿼리와 독립적으로 구분되지 않고, 연결되어 있다.

**예시**
```sql
-- 출판사별로 출판사의 평균 도서 가격보다 비싼 도서를 구하시오.
-- 모든 도서 중에 해당 도서의 출판사로부터 발행된 도서의 평균가격보다 큰 가격의 도서를 구하시오.
-- 서브쿼리에 현재 따지는 도서의 출판사가 전달되어서 서브쿼리에서 해당 출판사에서 발행된 도서의 평균가를 구해야 된다.
select b1.bookname, b1.publisher
  from book b1
 where b1.price > ( select avg(b2.price) from book b2 where b2.publisher = b1.publisher );
```

### 실행계획(execution plan)
* SQL 쿼리가 실행될 때 DB 엔진이 어떤 방식으로 데이터를 처리할지 보여주는 계획
* MySQL에서는 `EXPLAIN` 키워드 사용

**주의점**
1. 동일 데이터에 대한 동일 쿼리의 비용이 DB 마다 다르다.
2. 동일 테이블에 데이터 건수가 변경되면 비용이 달라진다.
3. 좋은 DBMS는 실행계획을 만드는 나름대로의 비책이 있다.
<br>

> * 어떤 쿼리를 작성할 때, 조인 또는 서브쿼리로 할 건지 판단해야 하고 이때 실행계획을 기본으로 선택
> * 조인이 더 빠르다. 서브쿼리가 더 빠르다.  선입견 갖지 말자.
> * 조인으로 작성된 쿼리는 DBMS 가 실행 계획을 작성할 때, 능동적으로 개입
> * 서브쿼리로 작성된 쿼리는 DBMS 가 실행 계획을 작성할 때, 능동적으로 개입하기 어렵다. <- 쿼리 자체가 순서가 정해져 있기 때문