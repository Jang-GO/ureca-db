# 0225
### SELECT

* 데이터를 조회할 때 사용한다.
    * 모든 컬럼 조회
    * 특정 컬럼만 조회
    * 컬럼 순서 변경하여 조회
    * 컬럼 별칭 사용하여 조회
```sql
select *  from book; -- 모든 컬럼을 만든 순서대로
select price, bookname, bookid, publisher from book; -- 모든 컬럼을 순서를 다르게
select bookname, price from book; -- 일부 컬럼
select publisher from book; -- 모든 출판사 ( 중복 포함 )
select distinct publisher from book; -- 모든 출판사 ( 중복 제거 )
```
> `DISTINCT` 키워드를 붙이면 중복없이 값을 유일하게 가져올 수 있다.

### WHERE - 조건식
* SELECT에 조건을 지정한다.
```sql
select * from book where price =7000; -- 모든 row 중 where 조건에 맞는 row 만 추출
select * from book where price >20000; -- 모든 row 중 where 조건에 맞는 row 만 추출
select * from book where price !=7000; -- 모든 row 중 where 조건에 맞는 row 만 추출 ( <>, != : 다른 조건 )
select * from book where bookid between 5 and 7;
select * from book where price between 10000 and 20000; -- 경계선 포함
select * from book where price >= 10000 and price <= 20000; -- 경계선 포함
```
* `BETWEEN` A AND B : A와 B 사이의 값 포함(경계값 포함)

```sql
select *
  from book
 where publisher = '굿스포츠' or  publisher = '대한미디어';
 
select *
  from book
 where publisher in (  '굿스포츠' ,'대한미디어' );  -- publisher 가 in 다음의 집합에 포함되는 것 추출 (권장)
 
select *
  from book
 where publisher not in (  '굿스포츠' ,'대한미디어' );  -- publisher 가 in 다음의 집합에 포함되지 않는 것 추출 (비 권장)
 
select *
  from book
 where publisher != '굿스포츠' and publisher != '대한미디어'; 
 ```
* `IN`, `NOT IN`으로 포함 여부 확인 가능
* `NOT IN` 사용시 발생 가능한 문제
    1. `NULL`이 포함 시 결과가 예상과 다를 수 있음
    2. `인덱스` 활용이 잘 안 됨(`FULL TABLE SCAN` 가능성, 모든 부정조건은 인덱스를 잘 못탐)

> `SELECT`로 조회할 때 조건들을 포함해서 조회를 한다면 이 조건들과 관련된 attribute에 `index`가 걸려있어야 한다.<br>
그렇지 않다면 데이터가 많아질 수록 조회 속도가 느려진다

### LIKE - 패턴 검색
* 와일드 카드 : `%`(0개 이상 문자), `_`(정확히 1개 문자)

```sql
select * from book where bookname like '축구의 역사';  -- wildcard 가 없으므로 = 과 동일한 비교
select * from book where bookname like '%축구%';  -- 비교 컬럼에 축구 두 글자가 포함되면 된다.
select * from book where bookname like '골프%';  -- 비교 컬럼에  반드시 골프로 시작.
select * from book where bookname like '%기술';  -- 비교 컬럼에 반드시 기술로 종료.
-- 복합 조건
select * from book where bookname like '%축구%' and price >= 20000;
select * from book where price <=10000 or price >=  30000;  -- 복합 조건이 3개 이상이면서 and 와 or 가 섞여 있는 경우 가독성을 위해서라도 () 를 활용
```

### ORDER BY - 정렬
```sql
-- order by 항상 맨 마지막에 수행되도록 query 작성 ( 결과물을 만드는 중간에 order by 포함되면 성능 하락의 원인이 된다. )
select * from book order by bookname; -- asc, desc (생략하면 asc)
select * from book order by bookname desc; -- 내림차순
select * from book order by price desc;

-- price기준으로 내림차순으로 정렬하되 같으면 bookname 기준으로 내림차순
select * from book order by price desc, bookname desc; 
```
> `ORDER BY`는 항상 쿼리의 마지막에 실행됨(성능 최적화를 위해)<br>
   정렬은 최종 결과에만 적용하여 불필요한 정렬 연산 방지

### SQL 작성 시 주의사항
* 문자열은 작은따옴표(`'`)로 표현
* 큰따옴표(`"`)는 주로 별칭에 사용될 수 있음
* 가독성이 중요함 - 들여쓰기, 줄바꿈 등으로 쿼리 가독성 높이기
* 긴 쿼리는 `SELECT`, `FROM`, `WHERE` 등 각 절을 줄바꿈하여 작성

### 실무 팁
* 중복 제거(`DISTINCT`)는 자주 사용되는 기능
* `NOT IN`은 인덱스를 효과적으로 활용하지 못해 성능이 저하될 수 있음
* `ORDER BY`는 항상 쿼리의 마지막에 실행되도록 작성해야 성능 최적화됨
* 게시판이나 검색 결과와 같은 데이터 조회 시, 필요한 조건으로 데이터를 먼저 필터링한 후 정렬하는 것이 효율적