-- 14-1. 날짜별 방문자 수 / 방문 횟수/ 페이지 뷰 집계하기

-- 날짜별 접근 데이터를 집계하는 쿼리
select substr(cast(stamp as string),1,10) as dt,  -- 날짜 추출
       count(distinct long_session) as access_users, -- 쿠키 계산
       count(distinct short_session) as access_count, -- 방문 횟수 계산
       count(*) as page_view, -- 페이지 뷰 계산
       1.0*count(*)/nullif(count(distinct long_session), 0) as pv_per_user -- 1인당 페이지 뷰 수
from `ivory-program-349520.data.access_log`
group by dt -- select 구문에서 정의한 별칭 사용 가능
order by dt;
