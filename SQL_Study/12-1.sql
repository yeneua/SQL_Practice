-- 12-1. 등록 수의 추이와 경향 보기

-- 날짜별 등록 수의 추이
select register_date, count(distinct user_id) as register_count
from `data.mst_users`
group by register_date;


-- 월별 등록수 추이
with
mst_users_with_year_month as(
    select
        *,
        substr(cast(register_date as string),1,7) as year_month
    from `data.mst_users`
)
select 
    year_month,
    count(distinct user_id) as register_count,
    lag(count(distinct user_id)) over(order by year_month) as last_month_count,
    1.0*count(distinct user_id)/lag(count(distinct user_id)) over(order by year_month) AS month_over_month_ratio
from mst_users_with_year_month
group by year_month;



-- 등록 디바이스별 추이
-- 등록한 디바이스가 어떤 것인지를 나타내기
with mst_users_with_year_month as (
    select *, substr(cast(register_date as string),1,7) as year_month
    from `data.mst_users`
)
select
    year_month,
    count(distinct user_id) as register_count,
    count(distinct case when register_device ='pc' then user_id end) as register_pc,
    count(distinct case when register_device='sp' then user_id end) as register_sp,
    count(distinct case when register_device='app' then user_id end) as register_app
from mst_users_with_year_month
group by year_month;