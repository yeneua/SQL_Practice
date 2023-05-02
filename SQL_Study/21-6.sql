-- 21-6. 검색 결과의 포괄성을 지표화하기

-- 검색 결과와 정답 아이템을 결합하는 쿼리
with
search_result_with_correct_items as (
	select coalesce(r.keyword, c.keyword) as keyword, -- r.keyword, c.keyword 어차피 같은 값이니까 null이 아닌 것을 가져옴(두개 테이블에 모두 존재할경우 같은 값임)
		   r.rank,
	  	   coalesce(r.item, c.item) as item, -- r.item, c.item 어차피 같은 값이니까 null이 아닌 값을 가져옴(두개 테이블에 모두 존재할경우 같은 값임)
		   case when c.item is not null then 1 else 0 end as correct -- 정답 아이템 테이블(c)에 있으면 1
	from search_result as r
		full outer join correct_result as c
		on r.keyword = c.keyword and r.item = c.item  -- '키워드+아이템'으로 full outer join
)
select *
from search_result_with_correct_items
order by keyword, rank;


-- 검색 결과 상위 n개의 재현율을 계산하는 쿼리
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
, search_result_with_recall as (
	select *,
		   -- 검색 결과 상위에서 정답 데이터에 포함되는 아이템 수의 누계 구하기
		   sum(correct)
		   	over(partition by keyword order by coalesce(rank, 10000) asc -- rank가 NULL이면 정렬 순서 마지막위치 -> 편의상 큰 값으로 변환
			 rows between unbounded preceding and current row) as cum_correct, -- 이전행 전부 ~ 현재 행
		   case when rank is null then 0.0 -- 검색 결과에 포함되지 않은 아이템(rank가 NULL)은 편의상 0으로 다루기
		    else
			 100.0 * sum(correct)
			  over(partition by keyword order by coalesce(rank, 10000) asc
			   rows between unbounded preceding and current row) -- 이전 행 전부 ~ 현재 행
			 / sum(correct) over(partition by keyword) -- keyword 기준으로 correct 개수 
		   end as recalls

	from search_result_with_correct_items
)
select *
from search_result_with_recall
order by keyword, rank;


-- 검색 결과 상위 5개의 재현율을 키워드별로 추출하는 쿼리
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
, search_result_with_recall as (
	select *,
		   sum(correct)
		   	over(partition by keyword order by coalesce(rank, 10000) asc
			 rows between unbounded preceding and current row) as cum_correct,
		   case when rank is null then 0.0
		    else
			 100.0 * sum(correct)
			  over(partition by keyword order by coalesce(rank, 10000) asc
			   rows between unbounded preceding and current row)
			 / sum(correct) over(partition by keyword) 
		   end as recall
	from search_result_with_correct_items
)
,
recall_over_rank_5 as (
	select keyword, rank, recall,
		   row_number()  -- 검색 결과 순위 높은 순으로 번호 붙이기
		    over(partition by keyword order by coalesce(rank,0) desc) as desc_number -- 검색 결과 나오지 않는 아이템은 편의상 0 부여 
	from search_result_with_recall
	where coalesce(rank, 0) <= 5 -- 검색결과 상위 5개 이하 또는 검색결과에 포함되지 않은 아이템만 출력
)
select keyword, recall as recall_at_5
from recall_over_rank_5
where desc_number = 1; -- 검색 결과 상위 5개 중에서 가장 순위 높은 레코드 추출


-- 검색 엔진 전체의 평균 재현율을 계산하는 쿼리
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
, search_result_with_recall as (
	select *,
		   sum(correct)
		   	over(partition by keyword order by coalesce(rank, 10000) asc
			 rows between unbounded preceding and current row) as cum_correct,
		   case when rank is null then 0.0
		    else
			 100.0 * sum(correct)
			  over(partition by keyword order by coalesce(rank, 10000) asc
			   rows between unbounded preceding and current row)
			 / sum(correct) over(partition by keyword) 
		   end as recall
	from search_result_with_correct_items
)
,
recall_over_rank_5 as (
	select keyword, rank, recall,
		   row_number()
		    over(partition by keyword order by coalesce(rank,0) desc) as desc_number 
	from search_result_with_recall
	where coalesce(rank, 0) <= 5
)
select avg(recall) as average_recall_at_5
from recall_over_rank_5
where desc_number = 1;