-- 20-1. 여러 개의 데이터셋 비교하기

-- 추가된 마스터 데이터를 추출하는 쿼리
select new_mst.*
from mst_products_20170101 as new_mst
    left outer join mst_products_20161201 as old_mst -- 한쪽에만 존재하는 레코드 추출
    on new_mst.product_id=old_mst.product_id
    where old_mst.product_id is null; -- 새로운 마스터 테이블에만 존재하는 레코드 추출

