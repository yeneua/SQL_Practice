-- 11-2. 연령별 구분 집계하기

-- 사용자의 생일을 계산하는 쿼리
with
mst_users_with_int_birth_date as (
    select
        *,
        20230101 as int_specific_date,
        cast(replace(substr(cast(birth_date as string),1, 10), '-', '') as int64) as int_birth_date
    from
        ivory-program-349520.data.mst_users
)
, mst_users_with_age as (
    select
        *,
        floor((int_specific_date - int_birth_date) / 10000) as age
    from
        mst_users_with_int_birth_date
)
select
    user_id,sex,birth_date,age
from
    mst_users_with_age;



-- 성별과 연령으로 연령별 구분을 계산하는 쿼리
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
select * from mst_users_with_category
order by user_id;


-- 연령별 구분의 사람 수를 계산하는 쿼리
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
    category,
    count(1) as user_count
from mst_users_with_category
group by category;