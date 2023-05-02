-- 21-7. 검색 결과의 타당성을 지표화하기
-- => 정확률/정밀도(Precision)

-- 검색 결과 상위 n개의 정확률을 계산하는 쿼리
with
search_result_with_correct_items as (
    select coalesce(r.keyword, c.keyword) as keyword,
           r.rank,
           coalesce(r.item, c.item) as item,
           case when c.item is not null then 1 else 0 end as correct
    from search_result as r
        full outer join correct_result as c
        on r.keyword = c.keyword and r.item = c.item
)
, search_result_with_precision as (
    select *,
           sum(correct)
            over(partition by keyword order by coalesce(rank, 10000) asc
             rows between unbounded preceding and current row) as cum_correct, -- 키워드별로 정답 아이템 누계합
          case
           when rank is null then 0.0
           else 100.0 * sum(correct)
                         over(partition by keyword order by coalesce(rank, 10000) asc
                          rows between unbounded preceding and current row) -- (분자)
                / count(1)
                   over(partition by keyword order by coalesce(rank,10000) asc
                    rows between unbounded preceding and current row) -- (분모) 키워드별로 누계 아이템 수
          end as precision
    from search_result_with_correct_items
)
select *
from search_result_with_precision
order by keyword, rank;


-- 검색 결과 상위 5개의 정확률을 키워드별로 추출한 쿼리
with
search_result_with_correct_items as (
    select coalesce(r.keyword, c.keyword) as keyword,
           r.rank,
           coalesce(r.item, c.item) as item,
           case when c.item is not null then 1 else 0 end as correct
    from search_result as r
        full outer join correct_result as c
        on r.keyword = c.keyword and r.item = c.item
)
, search_result_with_precision as (
    select *,
           sum(correct)
            over(partition by keyword order by coalesce(rank, 10000) asc
             rows between unbounded preceding and current row) as cum_correct,
          case
           when rank is null then 0.0
           else 100.0 * sum(correct)
                         over(partition by keyword order by coalesce(rank, 10000) asc
                          rows between unbounded preceding and current row)
                / count(1)
                   over(partition by keyword order by coalesce(rank,10000) asc
                    rows between unbounded preceding and current row)
          end as precision
    from search_result_with_correct_items
)
, precision_over_rank_5 as (
    select keyword, rank, precision,
           row_number()
            over(partition by keyword order by coalesce(rank,0) desc) as desc_number -- 검색 결과 순위가 높은 순서로 번호 붙임. 검색 결과 나오지 않는 아이템 -> 0
    from search_result_with_precision
    where coalesce(rank, 0) <= 5 -- 상위 5개 이하 or 검색 결과에 나오지 않는 아이템
)
select keyword, precision as precision_at_5
from precision_over_rank_5
where desc_number = 1;


-- 검색 엔진 전체의 평균 정확률을 계산하는 쿼리
with
search_result_with_correct_items as (
    select coalesce(r.keyword, c.keyword) as keyword,
           r.rank,
           coalesce(r.item, c.item) as item,
           case when c.item is not null then 1 else 0 end as correct
    from search_result as r
        full outer join correct_result as c
        on r.keyword = c.keyword and r.item = c.item
)
, search_result_with_precision as (
    select *,
           sum(correct)
            over(partition by keyword order by coalesce(rank, 10000) asc
             rows between unbounded preceding and current row) as cum_correct,
          case
           when rank is null then 0.0
           else 100.0 * sum(correct)
                         over(partition by keyword order by coalesce(rank, 10000) asc
                          rows between unbounded preceding and current row)
                / count(1)
                   over(partition by keyword order by coalesce(rank,10000) asc
                    rows between unbounded preceding and current row)
          end as precision
    from search_result_with_correct_items
)
, precision_over_rank_5 as (
    select keyword, rank, precision,
           row_number()
            over(partition by keyword order by coalesce(rank,0) desc) as desc_number
    from search_result_with_precision
    where coalesce(rank, 0) <= 5
)
select avg(precision) as average_precision_at_5
from precision_over_rank_5
where desc_number = 1; -- 상위 5개 중에서 1위만 추출