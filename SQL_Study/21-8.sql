-- 21-8. 검색 결과 순위와 관련된 지표 계산하기

-- 정답 아이템별로 적합률을 추출하는 쿼리
with
search_result_with_correct_items as (
	select coalesce(r.keyword, c.keyword) as keyword,
		   r.rank,
	  	   coalesce(r.item, c.item) as item,
		   case when c.item is not null then 1 else 0 end as correct
	from search_result as r
		full outer join correct_result as c
		on r.keyword = c.keyword and r.item = c.item 
),
search_result_with_precision as (
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
select keyword, rank, precision
from search_result_with_precision
where correct = 1; -- 정답 아이템(correct 컬럼의 플래그가 1)별로 정확률 추출


-- 검색 키워드별로 정확률의 평균을 계산하는 쿼리
with
search_result_with_correct_items as (
	select coalesce(r.keyword, c.keyword) as keyword,
		   r.rank,
	  	   coalesce(r.item, c.item) as item,
		   case when c.item is not null then 1 else 0 end as correct
	from search_result as r
		full outer join correct_result as c
		on r.keyword = c.keyword and r.item = c.item 
),
search_result_with_precision as (
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
),
average_precision_for_keywords as (
    select keyword, avg(precision) as average_precision
    from search_result_with_precision
    where correct = 1
    group by keyword -- 검색 키워드별로
)
select * from average_precision_for_keywords;


-- 검색 엔진의 MAP(mean average precision)을 계산하는 쿼리
with
search_result_with_correct_items as (
	select coalesce(r.keyword, c.keyword) as keyword,
		   r.rank,
	  	   coalesce(r.item, c.item) as item,
		   case when c.item is not null then 1 else 0 end as correct
	from search_result as r
		full outer join correct_result as c
		on r.keyword = c.keyword and r.item = c.item 
),
search_result_with_precision as (
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
),
average_precision_for_keywords as (
    select keyword, avg(precision) as average_precision
    from search_result_with_precision
    where correct = 1
    group by keyword
)
select avg(average_precision) as mean_average_precision -- 평균(검색 키워드별로 정확률평균)
from average_precision_for_keywords;