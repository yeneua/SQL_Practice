-- 19-2. 로그 중복 검출하기

-- 사용자와 상품의 조합에 대한 중복을 확인하는 쿼리
select user_id, products,
       string_agg(session,',') as session_list,
       string_agg(stamp,',') as stamp_list
from dup_action_log
group by user_id, products
having count(*) > 1; -- 조합이 중복된 레코드인지 확인

-- group by와 min을 사용해 중복을 배제하는 쿼리
select session,
       user_id,
       action,
       products,
       min(stamp) as stamp -- 가장 오래된 타임스탬프만 남기기
from dup_action_log
group by session, user_id, action, products;

-- row_number를 사용해 중복을 배제하는 쿼리
with
dup_action_log_with_order_num as (
    select *,
           row_number()
            over(
                partition by session, user_id, action, products
                order by stamp -- 기본;오름차순 - 오래된 타임스탬프가 1번
            ) as order_num
    from dup_action_log
)
select session, user_id, action, products, stamp
from dup_action_log_with_order_num
where order_num = 1; -- 중복제거 - 순번이 1인 데이터만 남기기

-- 이전 액션으로부터의 경과 시간을 계산하는 쿼리(세션 ID 사용x, 타임스탬프 간격으로 중복 확인)
with
dup_action_log_with_lag_seconds as (
    select user_id, action, products, stamp,
           extract(epoch from stamp::timestamp - lag(stamp::timestamp) over(partition by user_id, action, products order by stamp)
           ) as lag_seconds
    from dup_action_log
)
select * from dup_action_log_with_lag_seconds
order by stamp;
-- 1. user_id, action, products를 기준으로 stamp를 오름차순 정렬하고
-- 2. 그 이전의 행의 stamp 값을 timestamp 자료형으로 변환해서 가져온다.
-- 3. 레코드 값 시각  - 이전행의 값
-- 4. epoch(field FROM source) : 초(epoch) 단위로 변경하기

-- 30분 이내의 같은 액션을 중복으로 보고 배제하는 쿼리(세션 ID 사용x, 타임스탬프 간격으로 중복 확인)
with
dup_action_log_with_lag_seconds as (
    select user_id, action, products, stamp,
           extract(epoch from stamp::timestamp - lag(stamp::timestamp) over(partition by user_id, action, products order by stamp)
           ) as lag_seconds
    from dup_action_log
)
select user_id, action, products, stamp
from dup_action_log_with_lag_seconds
where(lag_seconds is null or lag_seconds >= 30 * 60)
order by stamp;