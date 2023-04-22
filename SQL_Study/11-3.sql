-- 11-3. 연령별 구분의 특징 추출하기

with
mst_users_with_int_birth_date as (
    select
        *,
        20230101 as int_specific_date,
        cast(replace(substring(cast(birth_date as string), 1, 10), '-', '') as integer) as int_birth_date
    from data.mst_users
),
mst_users_with_age as (
    select
        *,
        floor((int_specific_date - int_birth_date)/10000) as age
    from mst_users_with_int_birth_date
)
,
mst_users_with_category as (
    select
        user_id,
        sex,
        age,
        concat(
            case
                when 20 <= age then sex
                else ''
            end
            ,case
                when age between 4 and 12 then 'C'
                when age between 13 and 19 then 'T'
                when age between 20 and 34 then '1'
                when age between 35 and 49 then '2'
                when age >= 50 then '3'
            end
        ) as category
    from mst_users_with_age
)
select
    p.category as product_category,
    u.category as mst_users_with_category,
    count(*) as purchase_count
from ivory-program-349520.data.action_log as p
    join mst_users_with_category as u
    on p.user_id = u.user_id
where
 action = 'purchase'
group by p.category, u.category
order by p.category, u.category;