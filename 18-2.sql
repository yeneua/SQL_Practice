-- 18-2. 크롤러 제외하기

-- 규칙을 기반으로 크롤러를 제외하는 쿼리
select *
from action_log_with_noise
where not
    (user_agent LIKE '%bot%'
    or user_agent LIKE '%crawler%'
    or user_agent LIKE '%spider%'
    or user_agent LIKE '%archiver');


-- 마스터 데이터를 사용해 제외하기
with
mst_bot_user_agent as (
              select '%bot%' as rule
    union all select '%crawler%' as rule
    union all select '%spider%' as rule
    union all select '%archiver%' as rule
),
filtered_action_log as (
    select
        l.stamp, l.session, l.action, l.products, l.url, l.ip, l.user_agent
    from action_log_with_noise as l
    where
        not exists(
                select 1
                from mst_bot_user_agent as m
                where l.user_agent LIKE m.rule -- 규칙이 존재하는지 비교
    )
)
select * from filtered_action_log;


-- 접근이 많은 사용자 에이전트를 확인하는 쿼리