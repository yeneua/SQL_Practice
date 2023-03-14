-- PostgreSQL
-- 15-1. 입구 페이지와 출구 페이지 파악하기

-- 각 세션의 입구 페이지와 출구 페이지 경로를 추출하는 쿼리
with
activity_log_with_landing_exit as (
    select session,
           path,
           stamp,
           first_value(path) -- path 중 가장 첫번째
            over(partition by session -- session 기준
                order by stamp asc -- 오름차순(시간순)
                    rows between unbounded preceding and unbounded following -- 모든 행 대상으로
            ) as landing,
           last_value(path) -- path 중 가장 마지막 레코드
            over(partition by session -- session 기준
                order by stamp asc -- 오름차순(시간순)
                    rows between unbounded preceding and unbounded following -- 모든 행 대상으로
            ) as exit
    from activity_log
)
select * from activity_log_with_landing_exit;



-- 각 세션의 입구 페이지와 출구 페이지를 기반으로 방문 횟수를 추출하는 쿼리
with
activity_log_with_landing_exit as (
    select session,
           path,
           stamp,
           first_value(path) over(partition by session
                                  order by stamp asc
                                  rows between unbounded preceding and unbounded following) as landing,
           last_value(path) over(partition by session
                                 order by stamp asc
                                 rows between unbounded preceding and unbounded following) as exit
    from activity_log
)
, landing_count as(
	select landing as path, count(distinct session) as count -- 방문 횟수 집계
	from activity_log_with_landing_exit
	group by landing
)
, exit_count as(
	select exit as path, count(distinct session) as count -- 방문 횟수 집계
	from activity_log_with_landing_exit
	group by exit
)
select 'landing' as type, * from landing_count
union all
select 'exit' as type, * from exit_count;


-- 세션별 입구 페이지와 출구 페이지의 조합 집계
-- 어떤 페이지에서 조회를 하기 시작해서 어떤 페이지에서 이탈하는지
with
activity_log_with_landing_exit as (
    select session,
           path,
           stamp,
           first_value(path)
            over(partition by session
                order by stamp asc
                    rows between unbounded preceding and unbounded following
            ) as landing,
           last_value(path)
            over(partition by session
                order by stamp access_count
                    rows between unbounded preceding and unbounded following
            ) as exit
    from activity_log
)
select landing, exit, count(distinct session) as count
from activity_log_with_landing_exit
group by landing,exit;