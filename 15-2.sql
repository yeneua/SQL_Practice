-- 15-2. 이탈률과 직귀율 계산하기

-- 경로별 이탈률을 집계하는 쿼리
with
activity_log_with_exit_flag as (
    select *,
           case when row_number() over(partition by session order by stamp desc) =1 then 1 else 0 end as is_exit -- 출구 페이지 판정
    from activity_log
)
select path,
       sum(is_exit) as exit_count,
       count(1) as page_view,
       avg(100.0*is_exit) as exit_ratio
from activity_log_with_exit_flag
group by path;


-- 경로들의 직귀율을 집계하는 쿼리
with
activity_log_with_landing_bounce_flag as (
    select *,
           case when row_number() over(partition by session order by stamp asc) = 1 then 1 else 0 end as is_landing, -- 입구 페이지 판정
           case when count(1) over (partition by session) = 1 then 1 else 0 end as is_bounce -- 직귀 판정 : session이 하나인 경우에 1(=첫번째 페이지만 보고 다른 페이지로 이동하지 않았다는 뜻)
    from activity_log
)
select path,
       sum(is_bounce) as bounce_count, -- 직귀 수
       sum(is_landing) as landing_count, -- 입구 수
       avg(100*case when is_landing = 1 then is_bounce end) as bounce_ratio -- 직귀율
from activity_log_with_landing_bounce_flag
group by path;