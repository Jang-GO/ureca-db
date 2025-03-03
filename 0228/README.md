# 0228
### 내장함수(Built-in Fuctions)
* 숫자 관련 함수
    * `ABS(value)` : 절대값 반환
    * `ROUND(value, 자릿수)` : 반올림 (자릿수 생략 가능)
* 문자열 관련 함수
    * `LENGTH(string)` : 바이트 단위 길이 반환
    * `CHAR_LENGTH(string)` : 문자 단위 길이 반환
* 날짜 관련 함수
    * `ADDDATE(date, INTERVAL n unit)` : 날짜 연산
    * `SYSDATE()` vs `NOW()`
        * `SYSDATE()` : 함수 실행 시점 시간 반환
        * `NOW()` : 쿼리문이 실행되는 시점의 시간 반환
* NULL 처리 함수  
    * `IFNULL(value, default)` : NULL이면 기본값 반환 (`Oracle : NVL`)
    * NULL과 연산하면 결과도 NULL이므로 `IS NULL`, `IS NOT NULL` 적절히 활용

```sql
SELECT ABS(-78), ABS(78) from dual; -- from dual은 오라클함수

select custid, round(sum(saleprice)/count(*), -2)
from orders
group by custid;

-- 한글 utf-8(3byte), utf-16(4byte), euc-kr(2byte)
-- 축구의 역사 : 한글 5개 + space 1개 (5x3 +1) = 16
select bookname, length(bookname), char_length(bookname)
from book where bookid in (1,10);

-- adddate
select adddate('2025-02-28', interval 5 day);

-- ifnull
select bookid, ifnull(price, 0) price from mybook;
```

### CASE WHEN 구문
* 그룹별 합계 구하기
```sql
SELECT department_id, SUM(salary)
FROM employees
WHERE department_id IN (60,90)
GROUP BY department_id;
```

* 단일 행에 여러 컬럼으로 표현
```sql
SELECT
    SUM(CASE WHEN department_id=60 THEN salary ELSE 0 END) AS sum60,
    SUM(CASE WHEN department_id=90 THEN salary ELSE 0 END) AS sum90
FROM employees
WHERE department_id IN (60,90);
```

### EXISTS vs IN
* `EXISTS` : 존재 여부 판단
* `EXISTS`는 서브쿼리의 결과가 최소 하나의 row라도 있다면 TRUE 반환
* `NOT EXISTS`는 서브쿼리의 결과가 단 하나의 row도 없다면 TRUE 반환
```sql
-- 왼쪽 subquery 의 customer_order가 100건이면 오른쪽 customer 1건에 대해 왼쪽 100과 비교를 하다가 1건이라도 나오면
-- 더이상 따지지 않고 true 처리
select * from customer c where exists (select co.customer_id from customer_order co where c.custid = co.customer_id);

-- 왼쪽 subquery 의 customer_order가 100건이면 오른쪽 customer 1건에 대해 왼쪽 100과 비교를 하다가 1건이라도 나오면
-- 더이상 따지지 않고 false 처리
select * from customer c where not exists (select customer_id from customer_order co where c.custid = co.customer_id); -- 몇개 안될땐 in이 유리
```

**NULL 주의**
```sql
-- 1번은 blacklist에 없는데 not in 계산 1!=2 && 1!=null 가 true여야 되는데 null 연산에서 unknown이 나오면서 1번이 안나옴
-- 즉 not in 쓸때는 null 조심
select * from customer where custid not in (select customer_id from blacklist); -- 0건
-- null 을 제외한 not in 처리가 필요
select * from customer where custid not in (select customer_id from blacklist where customer_id is not null);

select * from customer c where not exists (select b.customer_id from blacklist b where c.custid = b.customer_id);
```
* `NOT IN`: NULL 고려 필요
* `NOT EXISTS`: NULL 고려 불필요, 인덱스 활용 가능

### 뷰
* 아래는 보고서처럼 보이도록 데이터를 조회하는 쿼리

```sql
select o.orderid, o.custid, c.name, b.bookid, b.bookname, o.saleprice, o.orderdate
 from customer c, orders o, book b
where c.custid = o.custid
	and b.bookid = o.bookid;
```

* 뷰를 이용하면 아래와 같이 작성

```sql
-- View 를 이용한 보고서 (뷰는 쿼리를 저장해놓는거라고 생각)
-- View 를 생성하는 시점에 데이터까지 생성 X, query만 보관
create view VOrders as
select o.orderid, o.custid, c.name, b.bookid, b.bookname, o.saleprice, o.orderdate
 from customer c, orders o, book b
where c.custid = o.custid
	and b.bookid = o.bookid;
```

* view는 데이터가 아닌 쿼리만 저장
* 접근 제한을 둘 수 있음
```sql
-- 은행, 통신 회사 인사팀, 영업팀(전체 데이터가 필요)... 콜센터(제한적인 데이터만 필요)
-- 중요 데이터가 포함된 테이블은 상담에 필요한 일부 컬럼만 콜센터가 사용하도록 한다.
-- 위 경우, 테이블을 콜센터에 직접 노출 X
```

### 인덱스 (Index)
* 인덱스의 목적
    1. 빠른 검색을 위해 별도 자료구조 구성 (정렬 포함)
    2. 데이터 추가/변경/삭제 시 재구성 필요
    3. 검색 성능 향상, 하지만 삽입/수정/삭제 성능 저하 가능
    4. PK, FK는 자동 인덱스 생성
> 거꾸로 특정 컬럼에 인덱스를 추가해도 검색이 개선되지 않고 오히려 느려진다.<br>
> 분포도가 낮은 컬럼( 예 : 성별 'M', 'F'이 각각 5백만건씩 있다면? )
> <br>분포도가 20% 이상이 되면 별로...

