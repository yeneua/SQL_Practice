-- 19강. 데이터 중복 검출하기

-- 19-1. 마스터 데이터의 중복 검출하기

-- 키의 중복을 확인하는 쿼리
select count(1) as total_num, count(distinct id) as key_num -- 전체 레코드 개수와 유니크한 레코드 개수 비교하기
from mst_categories;

-- 키가 중복되는 레코드 확인하기
select id, count(*) as record_num,
       string_agg(name, ',') as name_list, -- string_agg() : 칼럼값들을 하나로 합치는 역할
       string_agg(stamp,',') as stamp_list
from mst_categories
group by id
having count(*) > 1;


-- 윈도 함수를 사용해서 중복된 레코드를 압축하는 쿼리
with -- 원래 레코드 형식 그대로 출력됨
mst_categories_with_key_num as (
    select *,
           count(*) over(partition by id) as key_num
    from mst_categories
)
select * from mst_categories_with_key_num
where key_num > 1;