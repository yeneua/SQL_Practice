-- 18-1. 데이터 분산 계산하기

-- 세션별로 페이지 열람 수 랭킹 비율을 구하는 쿼리
with
session_count as (
    select
        session, count(1) as count
    from action_log_with_noise
    group by session
)
select session,
       count,
       rank() over(order by count desc) as rank,
       percent_rank() over(order by count desc) as precent_rank
from session_count;

-- url 접근 수 워스트 랭킹 비율을 출력하는 쿼리
with
url_count as (
    select url, count(*) as count
    from action_log_with_noise
    group by url
)
select
    url,
    count,
    rank() over(order by count asc) as rank, -- 워스트랭킹 -> 오름차순
    percent_rank() over(order by count asc) from url_count;