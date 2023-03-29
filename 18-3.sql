-- 18-3. 데이터 타당성 확인하기

-- 로그 데이터의 요건을 만족하는지 확인하는 쿼리

select
    action, avg(case when session is not null  then 1.0 else 0 end) as session, -- session은 반드시 not null
    avg(case when user_id is not null then 1.0 else 0 end) as user_id, -- user_id는 반드시 not null
    avg(case action -- category action=view인 경우 null, 아니면 not null
            when 'view' then
                case when category is null then 1.0 else 0.0 end
            else
                case when category is not null then 1.0 else 0.0 end
            end
    ) as category,
    avg(case action -- products action=view인 경우 null, 아니면 not null
            when 'view' then
                case when products is null then 1.0 else 0.0 end
            else
                case when products is not null then 1.0 else 0.0 end
            end
    ) as products,
    avg(case action -- amount action=purchase인 경우 null, 아니면 not null
            when 'purchase' then
                case when amount is not null then 1.0 else 0.0 end
            else
                case when amount is null then 1.0 else 0.0 end
            end
    ) as amount,
    avg(case when stamp is not null then 1.0 else 0.0 end) as stamp -- stamp는 not null
from invalid_action_log
group by action;