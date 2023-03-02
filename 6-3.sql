-- 6-3. 2개의 값 비율 계산하기

-- 정수 자료형의 데이터 나누기
select dt,ad_id, clicks/impressions AS ctr, clicks/impressions*100 as ctr_as_percent
from `ivory-program-349520.data.advertising_stats`
where dt = '2017-04-01'
order by dt,ad_id; --order by기본값은 오름차순

--0으로 나누는 것 피하기
select dt, ad_id, case when impressions > 0 then 100.0* clicks/impressions end as ctr_as_percent_by_case,
       100.0*clicks/NULLIF(impressions,0) as ctr_aw_percent_by_null --NULL전파:null을 포함함 데이터의  연산결과가 모두 null이되는 sql성질
from `ivory-program-349520.data.advertising_stats`
order by dt,ad_id;