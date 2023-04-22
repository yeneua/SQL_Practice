-- 6-5. 날짜/시간 계산하기

-- 미래 또는 과거의 날짜/시간을 계산하는 쿼리

select user_id, timestamp(register_stamp) as register_stamp,
                timestamp_add(timestamp(register_stamp), interval  1 hour) as after_1_hour, --timestamp_add()
                timestamp_sub(timestamp(register_stamp), interval 30 minute) as before_30_minutes --timestamp_sub()
from `data.mst_user_with_dates`;

select user_id, date(timestamp(register_stamp)) as register_date,
                date_add(date(timestamp(register_stamp)), interval 1 day) as after_1_day, --date_add()
                date_sub(date(timestamp(register_stamp)), interval 1 month) as before_1_month --date_sub()
from `data.mst_user_with_dates`;



-- 날짜 데이터들의 차이 계산하기
select user_id, current_date as today,
       date(timestamp(register_stamp)) as register_date,
       date_diff(current_date, date(timestamp(register_stamp)), day) as diff_days, --date_diff()
       date_diff(current_date, date(timestamp(register_stamp)),month) as diff_months,
       date_diff(current_date, date(timestamp(register_stamp)),year) as diff_years
from `data.mst_user_with_dates`;


-- 사용자의 생년월일로 나이 계산하기
select floor((20160228-20000229)/10000) as age; --2016.02.28시점에서 2000.02.29생일인사람 나이 계산. floor() : 소수점버림

-- *실행안됨. timestamp유형은 substring안됨
-- SELECT
-- user_id, substring(register_stamp, 1, 10) AS register_date, birth_date,
--           floor((CAST(replace(substring(register_stamp, 1, 10),'-','') AS integer) - CAST (replace(birth_date,'-','') AS integer)) / 10000) AS register_age,
--           floor((CAST(replace(CAST(CURRENT_DATE AS text),'-','') AS integer) - CAST(replace(birth_date,'-','') AS integer)) / 10000) AS current_age
-- from `data.mst_user_with_dates`;

--연부분차이 계산(생년월일 제대로 계산X)
select user_id, current_date as today, date(timestamp(register_stamp)) as register_date,
       date(timestamp(birth_date)) as birth_date,
       date_diff(current_date,date(timestamp(birth_date)),year) as current_age,
       date_diff(date(timestamp(register_stamp)),date(timestamp(birth_date)),year) as register_age --등록당시나이
from `data.mst_user_with_dates`;
