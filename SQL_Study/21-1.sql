-- 21-1. 검색 기능 평가하기

-- NoMatch 비율(검색결과가 0인 비율)을 집계하는 쿼리
select substring(stamp::varchar, 1, 10) as dt, -- substr, substring에서 timestamp자료형 문자열로 변환해주기
	   count(1) as search_count,
	   sum(case when result_num = 0 then 1 else 0 end) as no_match_count, -- 검색 결과가 0인 개수
	   avg(case when result_num = 0 then 1.0 else 0.0 end) as no_match_rate -- 검색 결과가 0인 비율
from access_log
where action = 'search'
group by dt;

-- NoMatch 키워드 집계하기
with
search_keyword_stat as (
select keyword,
	   result_num,
	   count(1) as search_count, -- 키워드 개수
	   100.0 * count(1) / count(1) over() as search_share -- 키워드 개수 / 전체 개수 * 100, count(1) over() : 전체 행 개수
from access_log
where action = 'search'
group by keyword, result_num
)
select keyword,
	   search_count, -- 키워드 검색 개수
	   search_share, -- nomatch를 포함한 전체에서의 비율
	   100.0 * search_count / sum(search_count) over() as no_match_share -- nomatch들 중에서 어떤 키워드가 비율 얼마나 차지하는지
from search_keyword_stat
where result_num = 0;