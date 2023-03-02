-- 12-2. 지속률과 정착률 산출하기

with
action_log_with_mst_users as (
    select
        u.user_id,
        u.register_date,
        date(timestamp(a.stamp)) as action_date,
        max(date(timestamp(a.stamp))) over() as latest_date,

        date_add(cast(u.register_date as date), interval 1 day) as next_day_1
    from `data.mst_users` as u
        left outer join
        `data.action_log` as a
        on u.user_id=a.user_id
)

select * from action_log_with_mst_users order by register_date;


-- 12-5
with
action_log_with_mst_users as (
    select
        u.user_id,
        u.register_date,
        date(timestamp(a.stamp)) as action_date,
        max(date(timestamp(a.stamp))) over() as latest_date,

        date_add(cast(u.register_date as date), interval 1 day) as next_day_1
    from `data.mst_users` as u
        left outer join
        `data.action_log` as a
        on u.user_id=a.user_id
)
, user_action_flag as (
    select
        user_id, register_date, sign(sum(case when next_day_1 <= latest_date then
                                         case when next_day_1 = action_date then 1 else 0 end
                                         end)
                                         ) as next_1_day_action
    from action_log_with_mst_users
    group by user_id, register_date
)
select * from user_action_flag
order by register_date, user_id;


-- 12-6
with
action_log_with_mst_users as (
    select
        u.user_id,
        u.register_date,
        date(timestamp(a.stamp)) as action_date,
        max(date(timestamp(a.stamp))) over() as latest_date,

        date_add(cast(u.register_date as date), interval 1 day) as next_day_1
    from `data.mst_users` as u
        left outer join
        `data.action_log` as a
        on u.user_id=a.user_id
)
, user_action_flag as (
    select
        user_id, register_date, sign(sum(case when next_day_1 <= latest_date then
                                         case when next_day_1 = action_date then 1 else 0 end
                                         end)
                                         ) as next_1_day_action
    from action_log_with_mst_users
    group by user_id, register_date
)
select register_date,
avg(100.0*next_1_day_action) as repeat_rate_1_day
from user_action_flag
group by register_date
order by register_date;


-- 12-7
with
repeat_interval as(
                      select '01 day repeat' as index_name, 1 as interval_date
            union all select '02 day repeat' as index_name, 2 as interval_date
            union all select '03 day repeat' as index_name, 3 as interval_date
            union all select '04 day repeat' as index_name, 4 as interval_date
            union all select '05 day repeat' as index_name, 5 as interval_date
            union all select '06 day repeat' as index_name, 6 as interval_date
            union all select '07 day repeat' as index_name, 7 as interval_date       
            )
select * from repeat_interval
order by index_name;


-- 12-8
with
repeat_interval as(
                      select '01 day repeat' as index_name, 1 as interval_date
            union all select '02 day repeat' as index_name, 2 as interval_date
            union all select '03 day repeat' as index_name, 3 as interval_date
            union all select '04 day repeat' as index_name, 4 as interval_date
            union all select '05 day repeat' as index_name, 5 as interval_date
            union all select '06 day repeat' as index_name, 6 as interval_date
            union all select '07 day repeat' as index_name, 7 as interval_date       
),
action_log_with_index_date as(
    select
        u.user_id,
        u.register_date,
        date(timestamp(a.stamp)) as action_date,
        max(date(timestamp(a.stamp))) over() as latest_date,
        r.index_name,
        date_add(cast(u.register_date as date), interval r.interval_date day) as index_date
    from `data.mst_users` as u
        left outer join
        `data.action_log` as a
        on u.user_id=a.user_id
        cross join
        repeat_interval as r
)
, user_action_flag as (
    select user_id,register_date,index_name,sign(sum(case when index_date <= latest_date then
                                                        case when index_date = action_date then 1 else 0 end
                                                    end)) as index_date_action
    from action_log_with_index_date
    group by user_id, register_date, index_name,index_date
)
select register_date,index_name,avg(100.0*index_date_action) as repeat_rate
from user_action_flag
group by register_date,index_name
order by register_date, index_name;



-- 12-9
with repeat_interval as(
              select '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
    union all select '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
    union all select '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
    union all select '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
)
select * from repeat_interval order by index_name;


-- 12-10
with repeat_interval as(
              select '07 day retention' as index_name, 1 as interval_begin_date, 7 as interval_end_date
    union all select '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
    union all select '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
    union all select '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
),
action_log_with_index_date as(
    select u.user_id,u.register_date,date(timestamp(a.stamp)) as action_date,max(date(timestamp(a.stamp))) over() as latest_date,r.index_name,
    date_add(cast(u.register_date as date), interval r.interval_begin_date day) as index_begin_date,
    date_add(cast(u.register_date as date), interval r.interval_end_date day) as index_end_date
    from `data.mst_users` as u
        left outer join
        `data.action_log` as a
        on u.user_id=a.user_id
        cross join repeat_interval as r
),
user_action_flag as (
    select user_id,register_date,index_name,sign(sum(case when index_end_date <= latest_date then
                                                        case when action_date between index_begin_date and index_end_date
                                                        then 1 else 0 end
                                                    end)) as index_date_action
    from action_log_with_index_date
    group by user_id,register_date,index_name,index_begin_date,index_end_date

)
select register_date,index_name,avg(100.0*index_date_action) as index_rate
from user_action_flag
group by register_date,index_name
order by register_date,index_name;


-- 12-11
with repeat_interval as(
              select '01 day retention' as index_name, 1 as interval_begin_date, 1 as interval_end_date
    union all select '02 day retention' as index_name, 2 as interval_begin_date, 2 as interval_end_date
    union all select '03 day retention' as index_name, 3 as interval_begin_date, 3 as interval_end_date
    union all select '04 day retention' as index_name, 4 as interval_begin_date, 4 as interval_end_date
    union all select '05 day retention' as index_name, 5 as interval_begin_date, 5 as interval_end_date
    union all select '06 day retention' as index_name, 6 as interval_begin_date, 6 as interval_end_date
    union all select '07 day retention' as index_name, 7 as interval_begin_date, 7 as interval_end_date
    union all select '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
    union all select '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
    union all select '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
)
select * from repeat_interval order by index_name;




-- 12-12
with repeat_interval as(
              select '01 day retention' as index_name, 1 as interval_begin_date, 1 as interval_end_date
    union all select '02 day retention' as index_name, 2 as interval_begin_date, 2 as interval_end_date
    union all select '03 day retention' as index_name, 3 as interval_begin_date, 3 as interval_end_date
    union all select '04 day retention' as index_name, 4 as interval_begin_date, 4 as interval_end_date
    union all select '05 day retention' as index_name, 5 as interval_begin_date, 5 as interval_end_date
    union all select '06 day retention' as index_name, 6 as interval_begin_date, 6 as interval_end_date
    union all select '07 day retention' as index_name, 7 as interval_begin_date, 7 as interval_end_date
    union all select '14 day retention' as index_name, 8 as interval_begin_date, 14 as interval_end_date
    union all select '21 day retention' as index_name, 15 as interval_begin_date, 21 as interval_end_date
    union all select '28 day retention' as index_name, 22 as interval_begin_date, 28 as interval_end_date
),
action_log_with_index_date as(
    select u.user_id,u.register_date,date(timestamp(a.stamp)) as action_date,max(date(timestamp(a.stamp))) over() as latest_date,r.index_name,
    date_add(cast(u.register_date as date), interval r.interval_begin_date day) as index_begin_date,
    date_add(cast(u.register_date as date), interval r.interval_end_date day) as index_end_date
    from `data.mst_users` as u
        left outer join
        `data.action_log` as a
        on u.user_id=a.user_id
        cross join repeat_interval as r
),
user_action_flag as (
    select user_id,register_date,index_name,sign(sum(case when index_end_date <= latest_date then
                                                        case when action_date between index_begin_date and index_end_date
                                                        then 1 else 0 end
                                                    end)) as index_date_action
    from action_log_with_index_date
    group by user_id,register_date,index_name,index_begin_date,index_end_date

)
select index_name,avg(100.0*index_date_action) as repeat_rate
from user_action_flag
group by index_name
order by index_name;