# 0310

### AUTOCOMMIT
* 데이터 변경 쿼리에 대하여 `AUTOCOMMIT`이 OFF면 **모든 변경 쿼리는 명시적으로 `COMMIT`을 실행해야 반영됨**.
* 트랜잭션의 시작
```sql
SET AUTOCOMMIT = 0;
SELECT @@AUTOCOMMIT; -- 결과: 0 (OFF)
```

### 트랜잭션
* 데이터베이스 안정성과 무결성 보장
* 쿼리 여러개를 하나의 작업 단위로 처리
```sql
SET AUTOCOMMIT = 0;
START TRANSACTION;

INSERT INTO customer VALUES (1, '홍길동');
INSERT INTO customer VALUES (2, '이길동');
INSERT INTO customer VALUES (3, '삼길동');

COMMIT;  -- 트랜잭션 완료
ROLLBACK;  -- 이미 커밋된 데이터는 롤백되지 않음
SET AUTOCOMMIT = 1;
```

### 트랜잭션의 4가지 성질
* **원자성(Atomicity)** : 트랜잭션에 포함된 작업은 전부 수행되거나 수행되지 않아야 한다.
* **일관성(Consistency)** : 트랜잭션을 수행하기 전이나 수행한 후나 데이터베이스는 항상 일관된 상태를 유지해야 한다.
* **고립성(Isolation)** : 수행 중인 트랜잭션에 다른 트랜잭션이 끼어들어 변경 중인 데이터 값을 훼손하는 일이 없어야 한다. 
* **원자성(Atomicity)** : 수행을 성공적으로 완료한 트랜잭션은 변경한 데이터를 영구히 저장해야 한다. 저장된 데이터베이스는 저장 직후 혹은 어느 때나 발생할 수 있는 정전, 장애, 오류에 영향을 받지 않아야 한다.

### SAVEPOINT
* 트랜잭션 중간에 세이브 포인트를 만들어 그 지점 까지만 `ROLLBACK`할 수 있다.
```sql
TRUNCATE TABLE customer;  -- 테이블 전체 삭제 (롤백 불가)
SELECT * FROM customer;  -- 데이터 확인

SET AUTOCOMMIT = 0;
START TRANSACTION;

-- A, B, C 작업 수행
INSERT INTO customer VALUES (1, '홍길동');
INSERT INTO customer VALUES (2, '이길동');

SAVEPOINT s1; -- 특정 지점 저장

-- D 작업 수행
INSERT INTO customer VALUES (3, '삼길동');

ROLLBACK TO s1; -- s1 지점으로 롤백 (삼길동 INSERT 취소)
COMMIT;  -- 홍길동, 이길동만 반영

SET AUTOCOMMIT = 1;
```
> `TRUNCATE`는 롤백이 불가능하므로 주의

### 트랜잭션 동시성 제어
* 갱신 손실 문제 : 두 트랜잭션이 한 개의 데이터를 동시애 갱신(update)할 때 발생
* 즉, (쓰기, 쓰기)인 상황에서 발생
* 한 트랜잭션이 row에 대하여 락을 획득하면, 다른 트랜잭션은 락을 얻을때 까지 대기
    * 데이터에 대한 갱신을 순차적으로 진행하여 갱신 손실 문제 해결

**락의 종류**
* 트랜잭션이 다루는 데이터는 read-only data, 읽고 쓰는 데이터, 쓰기 전용 데이터가 있다.
* 공유 락(Shared Lock) : 트랜잭션이 읽기를 할 때 사용하는 락
    * 공유 락은 여러 트랜잭션이 동시에 같은 데이터를 읽을 수 있음
* 배타 락(Exclusive Lock) : 읽기/쓰기를 할 때 사용하는 락
    * 트랜잭션이 락을 해제할 때 까지 모든 트랜잭션의 접근을 차단
* 갭 락(Gap Lock) : `REPEATABLE READ`에서 팬텀 리드를 방지하기 위해 사용
    
### 데드락
* 두 개 이상의 트랜잭션이 서로가 필요로 하는 리소스를 점유하고 있어 무한 대기 상태에 빠지는 현상
* MySQL에서는 일반적으로 `InnoDB` 스토리지 엔진을 사용하며, 데드락이 발생하면 `ROLLBACK`을 통해 한 쪽의 트랜잭션을 강제 해제함.

```sql
-- 세션 1
START TRANSACTION;
UPDATE book SET price = 5000 WHERE bookId = 1; -- 1번 lock
UPDATE book SET price = 5000 WHERE bookId = 2; -- 2번 lock (여기서 대기 발생)
COMMIT;

-- 세션 2 (거꾸로 접근)
START TRANSACTION;
UPDATE book SET price = 4000 WHERE bookId = 2; -- 2번 lock
UPDATE book SET price = 4000 WHERE bookId = 1; -- 1번 lock (데드락 발생)
COMMIT;
```
* 해결 방안 : 트랜잭션 순서 일관성 유지, 락 타임아웃 설정, 락 범위 최소화

### 트랜잭션 격리 수준 (Isolation Levels)
* 한 트랜잭션은 읽기, 다른 트랜잭션은 쓰기를 진행
* 읽는 트랜잭션이 쓰는 트랜잭션의 변화를 어떻게 대응할 것인가 하는 정책에 따라 다른 결과를 보여준다.
* 격리 수준이 높을수록 동시성은 낮아지고, 낮을수록 동시성은 높아지지만 데이터 불일치 문제가 발생할 수 있음

| 격리 수준  | 설명 | 발생할 수 있는 문제
| --- | --- | --- |
| READ UNCOMMITED | 다른 트랜잭션이 `COMMIT`하기 전에 변경된 데이터를 읽을 수 있음 | Dirty Read
| READ COMMITED | `COMMIT`된 데이터만 읽을 수 있음. 같은 트랜잭션 내에서 같은 데이터를 여러 번 읽으면 값이 달라질 수도 있음 | Non-Repeatable Read
| REPEATABLE READ | 같은 트랜잭션 내에서는 동일한 데이터를 읽으면 항상 같은 값을 보장 | Phantom Read (팬텀 리드)
| SERIALIZABLE | 가장 높은 수준. 모든 트랜잭션이 직렬적으로 실행되어 동시성이 거의 없음 | 성능 저하

```sql
-- Read Uncommitted (Dirty Read 발생 가능)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM users WHERE id = 1;
-- 다른 트랜잭션이 id = 1인 데이터를 바꾸면 바뀐게 읽힘
COMMIT;

-- Read Committed (Non-Repeatable Read 발생 가능)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM users WHERE id = 1;
-- 다른 트랜잭션이 id = 1인 데이터를 바꾸고 커밋하면 바뀐게 읽힘
COMMIT;

-- Repeatable Read (Phantom Read 발생 가능)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM users WHERE age BETWEEN 10 AND 30;
-- 다른 트랜잭션이 age BETWEEN 10 AND 30 범위에 새로운 데이터를 삽입하고 커밋하면 바뀐게 읽힘
COMMIT;
```
> MySQL에서 `Repeatable Read`는 트랜잭션이 시작하고 조회한 행들에 대한 `SNAPSHOT`을 구축하여 자료를 가져온다. <br>
> 따라서, 일반적으로 트랜잭션 내에서 같은 `SELECT`를 여러 번 실행해도 기존 데이터는 변경되지 않지만, 새로운 데이터가 삽입되면 결과에 나타날 수도 있다.(Phantom Read)<br>
> 그러나, MySQL에서는 `Gap Lock`을 통해 어느정도 방지가 된다.<br>
> [Gap Lock 참고링크](https://medium.com/daangn/mysql-gap-lock-%EB%91%90%EB%B2%88%EC%A7%B8-%EC%9D%B4%EC%95%BC%EA%B8%B0-49727c005084)