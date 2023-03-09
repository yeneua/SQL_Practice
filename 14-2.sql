-- 14-2. 페이지 별 쿠키/ 방문 횟수/ 페이지 뷰 집계하기

-- URL별로 집계하기
select url,
       count(distinct short_session) as accesss_count,
       count(distinct long_session) as access_users,
       count(*) as page_view
from `ivory-program-349520.data.access_log`
group by url;

-- 경로별로 집계하기
with
access_log_with_path as (
  select *, regexp_extract(url, '//[^/]+([^?#]+)') as url_path
from `ivory-program-349520.data.access_log`
)
select url_path,
       count(distinct short_session) as access_count,
       count(distinct long_session) as access_users,
       count(*) as page_view
from access_log_with_path
group by url_path;

-- url에 의미를 부여해서 집계하기
with access_log_with_path as (
    select *, regexp_extract(url, '//[^/]+([^?#]+)') as url_path
from `ivory-program-349520.data.access_log`
)
, access_log_with_split_path as ( --첫번째요소와 두번째 요소 추출하기
    select *,
           split(url_path, '/')[SAFE_ORDINAL(2)] AS path1,
           split(url_path, '/')[SAFE_ORDINAL(3)] AS path2
    from access_log_with_path
)
, access_log_with_page_name as (
    select *, case when path1 = 'list' then
                case when path2 = 'newly' then 'newly_list' else 'category_list' end
              else url_path end as page_name
    from access_log_with_split_path
)
select page_name, count(distinct short_session) as access_count,
       count(distinct long_session) as access_users,
       count(*) as page_view
from access_log_with_page_name
group by page_name
order by page_name;