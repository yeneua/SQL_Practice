-- 21-2. 재검색 비율과 키워드 집계하기

-- 검색 화면과 상세 화면의 접근 로그에 다음 줄의 액션을 기록하는 쿼리
with
access_log_with_next_action as (
select stamp,
	   session,
	   action,
	   lead(action) over(partition by session order by stamp asc) as next_action -- 이후 action을 가져옴. session을 기준으로 stamp 오름차순
from access_log
)
select *
from access_log_with_next_action
order by session, stamp;


-- 재검색 비율을 집계하는 쿼리
with
access_log_with_next_action as (
select stamp,
	   session,
	   action,
	   lead(action) over(partition by session order by stamp asc) as next_action
from access_log
)
select substring(stamp::varchar,1,10) as dt,
	   count(1) as search_count,
	   sum(case when next_action='search' then 1 else 0 end) as retry_count, -- 재검색 수
	   avg(case when next_action='search' then 1 else 0 end) as retry_rate -- 재검색 비율
from access_log_with_next_action
where action='search'
group by dt;


-- 재검색 키워드를 집계하는 쿼리
with
access_log_with_next_search as (
select stamp,
	   session,
	   action,
	   keyword,
	   result_num,
	   lead(action) over(partition by session order by stamp asc) as next_action,
	   lead(keyword) over(partition by session order by stamp asc) as next_keyword,
	   lead(result_num) over(partition by session order by stamp asc) as next_result_num
from access_log
)
select keyword,
	   result_num,
	   count(1) as retry_count,
	   next_keyword,
	   next_result_num
from access_log_with_next_search
where action = 'search' and next_action = 'search'
group by keyword, result_num, next_keyword, next_result_num;