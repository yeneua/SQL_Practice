-- 15-3. 성과로 이어지는 페이지 파악하기

-- 컨버전 페이지보다 이전 접근에 플래그를 추가하는 쿼리
with
activity_log_with_conversion_flag as (
    select session, stamp, path,
           sign(sum(case when path = '/complete' then 1 else 0 end) -- 성과 발생시키는 컨버전 페이지의 이전 접근에 플래그 추가
                over(partition by session order by stamp desc
                    rows between unbounded preceding and current row))
            as has_conversion
    from activity_log
)
select * from activity_log_with_conversion_flag
order by session,stamp;


-- 경로들의 방문 횟수와 구성 수를 집계하는 쿼리
with
activity_log_with_conversion_flag as (
    select session, stamp, path,
           sign(sum(case when path = '/complete' then 1 else 0 end)
                over(partition by session order by stamp desc
                    rows between unbounded preceding and current row))
            as has_conversion
    from activity_log
)
select path,
       count(distinct session) as sessions, -- 방문횟수
       sum(has_conversion) as conversions, -- 성과 수
       1.0*sum(has_conversion)/count(distinct session) as cvr -- 성과 수 / 방문 횟수
from activity_log_with_conversion_flag
group by path;