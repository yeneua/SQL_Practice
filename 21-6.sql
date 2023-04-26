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