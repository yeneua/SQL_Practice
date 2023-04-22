-- 5-4. 날짜와 타임스탭프 다루기

-- 현재날짜와 타임스탬프 추출하기
select current_date AS dt, current_timestamp AS stamp,  -- 1. 상수
       current_date() AS dt_, current_timestamp() AS stamp_; -- 2. 함수

-- 지정한 값의 날짜/시각 데이터 추출하기
select cast('2001-11-17' AS date) AS dt, cast('2001-11-17 12:00:00' as timestamp) AS stamp, -- 1. cast(value AS type)
       date('2001-11-17') AS dt1, timestamp('2001-11-17 12:00:00') AS stamp1, -- 2. type(value)
       date '2001-11-17' AS dt2, timestamp '2001-11-17 12:00:00' AS stamp2; -- 3. type value

-- 날짜/시각에서 특정 필드 추출하기
select stamp,
       extract(YEAR from stamp) as year,
       extract(MONTH from stamp) as month,
       extract(DAY from stamp) as day,
       extract(HOUR from stamp) as hour
from (select cast('2001-11-17 12:00:00' as timestamp) as stamp) as a;

select stamp, substr(stamp, 1, 4) as year,
              substr(stamp, 6, 2) as month,
              substr(stamp, 9, 2) as day,
              substr(stamp, 12, 2) as hour,
              substr(stamp, 1, 7) as year_month
from (select cast('2001-11-17 14:00:00' as string) as stamp) as zzz;
