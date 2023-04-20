-- 20-2. 두 순위의 유사도 계산하기

-- 3개의 지표를 기반으로 순위 작성하는 쿼리
with
path_stat as ( -- 경로(path)별 방문횟수, 방문자수, 페이지수
select path,
	   count(distinct long_session) as access_users,
	   count(distinct short_session) as access_count,
	   count(*) as page_view
from access_log
group by path
)
, path_ranking as ( -- 방문 횟수(access_count), 방문자 수(access_user), 페이지 뷰(page_view)별로 순위 붙이기
select 'access_user' as type, path,
		rank() over(order by access_users desc) as rank -- 순위를 매기는데, access_users 내림차순으로
from path_stat
union all -- *type칼럼에서 abc순서대로 union됨
select 'access_count' as type, path,
		rank() over(order by access_count desc) as rank
from path_stat
union all
select 'page_view' as type, path,
		rank() over(order by page_view desc) as rank
from path_stat
)
select *
from path_ranking
order by type,rank;