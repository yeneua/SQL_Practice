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
       row_number() over(partition by r1.product order by sum(r1.score * r2.score) desc) as rank -- 유사도 순위(product 기준으로, r1.score*r2.score점수가 높은 순으로 점수부여)
from ratings as r1
    join ratings as r2
    on r1.user_id = r2.user_id -- 공통 사용자가 존재하는 상품 페어 만들기
where r1.product <> r2.product -- 같은 아이템의 경우 페어 제외
group by r1.product, r2.product -- 상품 조합으로 그룹화
order by target, rank;


-- 아이템 벡터를 L2 정규화하는 쿼리
with
ratings as (
    select user_id, product,
           sum(case when action = 'view' then 1 else 0 end) as view_count,
           sum(case when action ='purchase' then 1 else 0 end) as purchase_count,
           0.3 * sum(case when action = 'view' then 1 else 0 end) + 0.7 * sum(case when action = 'purchase' then 1 else 0 end) as score
    from action_log
    group by user_id, product
),
product_base_normalized_ratings as (
    select user_id, product, score,
           sqrt(sum(score * score) over(partition by product)) as norm,
           score / sqrt(sum(score * score) over(partition by product)) as norm_score -- norm을 각각의 점수로 나눔
    from ratings
)
select *
from product_base_normalized_ratings;


-- 정규화된 점수로 아이템의 유사도를 구하는 쿼리
with
ratings as (
    select user_id, product,
           sum(case when action = 'view' then 1 else 0 end) as view_count,
           sum(case when action ='purchase' then 1 else 0 end) as purchase_count,
           0.3 * sum(case when action = 'view' then 1 else 0 end) + 0.7 * sum(case when action = 'purchase' then 1 else 0 end) as score
    from action_log
    group by user_id, product
),
product_base_normalized_ratings as (
    select user_id, product, score,
           sqrt(sum(score * score) over(partition by product)) as norm,
           score / sqrt(sum(score * score) over(partition by product)) as norm_score
    from ratings
)
select r1.product as target, r2.product as related,
       count(r1.user_id) as users, -- 모든 아이템을 열람/구매한 사용자 수
       sum(r1.score * r2.score) as score,
       sum(r1.norm_score * r2.norm_score) as norm_score, -- (코사인유사도. 자기 자신과의 유사도는 1.0
       row_number() over(partition by r1.product order by sum(r1.norm_score * r2.norm_score) desc) as rank
from product_base_normalized_ratings as r1
    join product_base_normalized_ratings as r2
    on r1.user_id = r2.user_id
group by r1.product, r2.product
order by target, rank;