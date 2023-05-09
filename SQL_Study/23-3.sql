-- 23-3. 당신을 위한 추천 상품

-- 사용자끼리의 유사도를 계산하는 쿼리
with
ratings as (
    select user_id, product,
           sum(case when action = 'view' then 1 else 0 end) as view_count,
           sum(case when action ='purchase' then 1 else 0 end) as purchase_count,
           0.3 * sum(case when action = 'view' then 1 else 0 end) + 0.7 * sum(case when action = 'purchase' then 1 else 0 end) as score
    from action_log
    group by user_id, product
),
user_base_normalized_ratings as (
    select user_id, product, score,
           sqrt(sum(score * score) over(partition by user_id)) as norm, -- 사용자(user_id)별로 벡터 노름 계산하기
           score / sqrt(sum(score * score) over(partition by user_id)) as norm_score -- norm을 각각의 점수로 나눔
    from ratings
),
related_users as ( -- 경향이 비슷한 사용자 찾기
    select r1.user_id,
           r2.user_id as related_user,
           count(r1.product) as products,
           sum(r1.norm_score * r2.norm_score) as score,
           row_number() over(partition by r1.user_id order by sum(r1.norm_score * r2.norm_score) desc) as rank
    from user_base_normalized_ratings as r1
        join user_base_normalized_ratings as r2
        on r1.product = r2.product
    where r1.user_id <> r2.user_id -- 같은 사용자(본인) 제외
    group by r1.user_id, r2.user_id -- 사용자 조합
)
select *
from related_users
order by user_id, rank;


-- 순위도가 높은 유사 사용자를 기반으로 추천 아이템을 추출하는 쿼리
with
ratings as (
    select user_id, product,
           sum(case when action = 'view' then 1 else 0 end) as view_count,
           sum(case when action ='purchase' then 1 else 0 end) as purchase_count,
           0.3 * sum(case when action = 'view' then 1 else 0 end) + 0.7 * sum(case when action = 'purchase' then 1 else 0 end) as score
    from action_log
    group by user_id, product
),
user_base_normalized_ratings as (
    select user_id, product, score,
           sqrt(sum(score * score) over(partition by user_id)) as norm,
           score / sqrt(sum(score * score) over(partition by user_id)) as norm_score
    from ratings
),
related_users as (
    select r1.user_id,
           r2.user_id as related_user,
           count(r1.product) as products,
           sum(r1.norm_score * r2.norm_score) as score,
           row_number() over(partition by r1.user_id order by sum(r1.norm_score * r2.norm_score) desc) as rank
    from user_base_normalized_ratings as r1
        join user_base_normalized_ratings as r2
        on r1.product = r2.product
    where r1.user_id <> r2.user_id
    group by r1.user_id, r2.user_id
),
related_user_base_products as (
    select u.user_id, r.product,
           sum(u.score * r.score) as score,
           row_number() over(partition by u.user_id order by sum(u.score * r.score) desc) as rank
    from related_users as u
        join ratings as r
        on u.related_user = r.user_id
    where u.rank <= 1
    group by u.user_id, r.product
)
select *
from related_user_base_products
order by user_id;


-- 이미 구매한 아이템을 필터링하는 쿼리
with
ratings as (
    select user_id, product,
           sum(case when action = 'view' then 1 else 0 end) as view_count,
           sum(case when action ='purchase' then 1 else 0 end) as purchase_count,
           0.3 * sum(case when action = 'view' then 1 else 0 end) + 0.7 * sum(case when action = 'purchase' then 1 else 0 end) as score
    from action_log
    group by user_id, product
),
user_base_normalized_ratings as (
    select user_id, product, score,
           sqrt(sum(score * score) over(partition by user_id)) as norm,
           score / sqrt(sum(score * score) over(partition by user_id)) as norm_score
    from ratings
),
related_users as (
    select r1.user_id,
           r2.user_id as related_user,
           count(r1.product) as products,
           sum(r1.norm_score * r2.norm_score) as score,
           row_number() over(partition by r1.user_id order by sum(r1.norm_score * r2.norm_score) desc) as rank
    from user_base_normalized_ratings as r1
        join user_base_normalized_ratings as r2
        on r1.product = r2.product
    where r1.user_id <> r2.user_id
    group by r1.user_id, r2.user_id
),
related_user_base_products as (
    select u.user_id, r.product,
           sum(u.score * r.score) as score,
           row_number() over(partition by u.user_id order by sum(u.score * r.score) desc) as rank
    from related_users as u
        join ratings as r
        on u.related_user = r.user_id
    where u.rank <= 1
    group by u.user_id, r.product
)
select p.user_id,
       p.product,
       p.score,
       row_number() over(partition by p.user_id order by p.score desc) as rank
from related_user_base_products as p
    left join ratings as r
    on p.user_id = r.user_id and p.product = r.product
where coalesce(r.purchase_count, 0) = 0 -- 대상 사용자가 구매하지 않은 상품만 추천하기
order by p.user_id;