-- 23-2. 특정 아이템에 흥미가 있는 사람이 함께 찾아보는 아이템 검색

-- 열람 수와 구매 수를 조합한 점수를 계산하는 쿼리
with
ratings as (
    select user_id, product,
           sum(case when action = 'view' then 1 else 0 end) as view_count, -- 상품 열람수
           sum(case when action ='purchase' then 1 else 0 end) as purchase_count, -- 상품 구매수
           0.3 * sum(case when action = 'view' then 1 else 0 end) + 0.7 * sum(case when action = 'purchase' then 1 else 0 end) as score -- 열람수, 구매수에 3:7 가중치 부여
    from action_log
    group by user_id, product
)
select *
from ratings
order by user_id, score desc;



-- 아이템 사이의 유사도를 계산하고 순위를 생성하는 쿼리
with
ratings as (
    select user_id, product,
           sum(case when action = 'view' then 1 else 0 end) as view_count,
           sum(case when action ='purchase' then 1 else 0 end) as purchase_count,
           0.3 * sum(case when action = 'view' then 1 else 0 end) + 0.7 * sum(case when action = 'purchase' then 1 else 0 end) as score
    from action_log
    group by user_id, product
)
select r1.product as target,
       r2.product as related,
       count(r1.user_id) as users, -- 모든 아이템을 열람/구매한 사용자수
       sum(r1.score * r2.score) as score, -- 유사도 계산
       row_number() over(partition by r1.product order by sum(r1.score * r2.score) desc) as rank -- 유사도 순위
from ratings as r1
    join ratings as r2
    on r1.user_id = r2.user_id -- 공통 사용자가 존재하는 상품 페어 만들기
where r1.product <> r2.product -- 같은 아이템의 경우 페어 제외
group by r1.product, r2.product
order by target, rank;