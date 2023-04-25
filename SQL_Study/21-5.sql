-- 21-5. 검색 키워드 관련 지표의 집계 효율화하기

-- 검색과 관련된 지표를 집계하기 쉽게 중간 데이터를 생성하는 쿼리
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
),
search_log_with_next_action as (
    select *
    from access_log_with_next_search
    where action = 'search'
)
select *
from search_log_with_next_action
order by session, stamp;

select substring(stamp::varchar,1,10) as dt,
       avg(case when result_num = 0 then 1 else 0 end) as nomatch_rate, -- nomatch 비율
       avg(case when next_action = 'search' then 1 else 0 end) as retry_rate, -- 재검색 비율
       avg(case when next_action is null then 1 else 0 end) as exit_rate -- 이탈 비율
from search_log_with_next_action
group by dt;