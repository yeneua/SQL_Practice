-- 11-1. 사용자의 액션 수 집계하기

-- 액션과 관련된 지표 집계하기
with
stats AS (
    select count(distinct session) as total_uu
    from `ivory-program-349520.data.action_log`
)
select
    l.action, count(distinct l.session) as action_uu,
    count(1) as action_count,
    s.total_uu,
    100.0 * count(distinct l.session) / s.total_uu as usage_rate,
    1.0 * count(1) / count(distinct l.session) as count_per_user
from `ivory-program-349520.data.action_log` as l cross join stats as s
group by l.action, s.total_uu;

-- 로그인 사용자와 비로그인 사용자를 구분해서 집계하기
with
action_log_with_status as (
    select session, user_id, action, case when coalesce(user_id, '') <> '' then 'login' else 'guest' end as login_status -- user_id가 null 혹은 빈문자이면 guest
    from ivory-program-349520.data.action_log
)
select * from action_log_with_status;

-- *실행안됨
with
action_log_with_status as(
    select session, user_id, action, case when coalesce(user_id, '') <> '' then 'login' else 'guest' end as login_status
    from ivory-program-349520.data.action_log
)
select 
    coalesce(action, 'all') as action,
    coalesce(login_status, 'all') as login_status,
    count(distinct session) as action_uu,
    count(1) as action_count
from action_log_with_status
union all select action, login_status, action_uu, action_count;


-- 회원과 비회원을 구분해서 집계하기
with
action_log_with_status as (
    select session, user_id, action, case when
                                            coalesce(max(user_id)
                                                over(partition by session order by stamp rows between unbounded preceding and current row)
                                                ,'') <> ''
                                            then 'member'
                                        else 'none'
                                    end as member_status, stamp
    from ivory-program-349520.data.action_log)
select * from action_log_with_status;