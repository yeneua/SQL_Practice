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