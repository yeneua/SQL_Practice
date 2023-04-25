-- 21-3. 재검색 키워드를 분류해서 집계하기

-- 1. NoMatch에서의 조건 변경 : NoMatch에서 재검색 키워드를 집계하는 쿼리
with
access_log_with_next_search as (
	select stamp,
		   session,
		   action,
		   keyword,
		   result_num,
		   lead(action) over(partition by session order by stamp asc) as next_action,
		   lead(keyword) over(partition by session order by stamp asc) as next_keyword,
		   lead(result_num) over(partition by session order by stamp asc) as next_result_num
	from access_log
)
select keyword,
	   result_num,
	   count(1) as retry_count,
	   next_keyword,
	   next_result_num
from access_log_with_next_search
where action = 'search' and next_action = 'search' -- 재검색
	  and result_num = 0 -- nomatch 로그만 필터링하기
group by keyword,result_num,next_keyword,next_result_num;


-- 2. 검색 결과 필터링 : 검색 결과 필터링 시의 재검색 키워드를 집계하는 쿼리
with
access_log_with_next_search as (
    select stamp,
           session,
           action,
           keyword,
           result_num,
           lead(action) over(partition by session order by stamp asc) as next_action,
           lead(keyword) over(partition by session order by stamp asc) as next_keyword,
           lead(result_num) over(partition by session order by stamp asc) as next_result_num
    from access_log
)
select keyword, result_num, count(1) as retry_count, next_keyword, next_result_num
from access_log_with_next_search
where action ='search' and next_action = 'search'
      -- 원래 키워드를 포함하는 경우만 추출하기
      and next_keyword like concat('%',keyword,'%') -- concat() : 문자열 합치는 함수
    --   and next_keyword like '&' || keyword || '%'
group by keyword, result_num, next_keyword, next_result_num;


-- 3. 검색 키워드 변경 : 검색 키워드 변경 때 재검색을 집계하는 쿼리
with
access_log_with_next_search as (
    select stamp,
           session,
           action,
           keyword,
           result_num,
           lead(action) over(partition by session order by stamp asc) as next_action,
           lead(keyword) over(partition by session order by stamp asc) as next_keyword,
           lead(result_num) over(partition by session order by stamp asc) as next_result_num
    from access_log
)
select keyword, result_num, count(1) as retry_count, next_keyword, next_result_num
from access_log_with_next_search
where action ='search' and next_action = 'search'
      -- 원래 키워드를 포함하지 않는 검색결과만 추출
      and next_keyword not like concat('%',keyword,'%')
    --   and next_keyword not like '%' || keyword || '%'
group by keyword, result_num, next_keyword, next_result_num;