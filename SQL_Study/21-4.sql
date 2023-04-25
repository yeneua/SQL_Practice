-- 21-4. 검색 이탈 비율과 키워드 집계하기

-- 검색 이탈 비율을 집계하는 쿼리 - 검색 이탈 : action이 search이고, next_action이 NULL
with
access_log_with_next_action as (
select stamp,
	   session,
	   action,
	   lead(action) over(partition by session order by stamp asc) as next_action
from access_log
)
select substring(stamp::varchar,1,10) as dt,
       count(1) as search_count, -- 검색 수
       sum(case when next_action is null then 1 else 0 end) as exit_count, -- 이탈 수
       avg(case when next_action is null then 1 else 0 end) as exit_rate -- 이탈 비율
from access_log_with_next_action
where action = 'search'
group by dt
order by dt;


-- 검색 이탈 키워드를 집계하는 쿼리
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
	   count(1) as search_count, -- 검색 수
	   sum(case when next_action is null then 1 else 0 end) as exit_count, -- 이탈 수
	   avg(case when next_action is null then 1 else 0 end) as exit_rate, -- 이탈 비율
	   result_num
from access_log_with_next_search
where action = 'search'
group by keyword, result_num
having sum(case when next_action is null then 1 else 0 end) > 0; -- 이탈 비율이 0보다 큰 키워드만 추출

-- (내풀이)
with
access_log_with_next_search as (
    select action,
           keyword,
           result_num,
           lead(action) over(partition by session order by stamp asc) as next_action,
           lead(keyword) over(partition by session order by stamp asc) as next_keyword,
           lead(result_num) over(partition by session order by stamp asc) as next_result_num
    from access_log
)
select * from access_log_with_next_search
where action='search' and next_action is null;