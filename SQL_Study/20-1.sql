-- 20-1. 여러 개의 데이터셋 비교하기

-- 추가된 마스터 데이터를 추출하는 쿼리
select new_mst.*
from mst_products_20170101 as new_mst
    left outer join mst_products_20161201 as old_mst -- 한쪽에만 존재하는 레코드 추출
    on new_mst.product_id=old_mst.product_id
where old_mst.product_id is null; -- 새로운 마스터 테이블에만 존재하는 레코드 추출


-- 제거된 마스터 데이터 추출하기
select old_mst.*
from mst_products_20170101 as new_mst
    right outer join mst_products_20161201 as old_mst -- right outer join 활용
    on new_mst.product_id=old_mst.product_id
where new_mst.product_id is null;

select old_mst.*
from mst_products_20161201 as old_mst
    left outer join mst_products_20170101 as new_mst
    on old_mst.product_id=new_mst.product_id
where new_mst.product_id is null;


-- 갱신된 마스터 데이터 추출하기
-- (내풀이)
select new_mst.*
from mst_products_20170101 as new_mst
    inner join mst_products_20161201 as old_mst
    on new_mst.product_id = old_mst.product_id
where new_mst.updated_at != old_mst.updated_at; -- != 연산자도 가능

select new_mst.product_id, old_mst.name as old_name, old_mst.price as old_price, new_mst.name as new_name, new_mst.price as new_price, new_mst.updated_at
from mst_products_20170101 as new_mst
    join mst_products_20161201 as old_mst
    on new_mst.product_id = old_mst.product_id
where new_mst.updated_at <> old_mst.updated_at;


-- 변경된 마스터 데이터 모두 추출하기
select coalesce(new_mst.product_id, old_mst.product_id) as product_id,
	   coalesce(new_mst.name, old_mst.name) as name,
	   coalesce(new_mst.price, old_mst.price) as price,
	   coalesce(new_mst.updated_at, old_mst.updated_at) as updated_at,
	   case when old_mst.updated_at is null then 'added' -- 오래된 테이블의 값 null -> 추가
	   		when new_mst.updated_at is null then 'deleted' -- 새로운 테이블의 값 null -> 삭제
			when new_mst.updated_at <> old_mst.updated_at then 'updated' -- 이외의 경우(타임스탬프가 다른 경우) -> 갱신
	   end as status
from mst_products_20170101 as new_mst
	full outer join mst_products_20161201 as old_mst
	on new_mst.product_id=old_mst.product_id
where new_mst.updated_at is distinct from old_mst.updated_at; -- null을 포함한 비교(그냥 <> 연산자 쓰면 null값이 있는 행은 비교대상에서 제외됨)
-- where new_mst.updated_at != old_mst.updated_at or new_mst.updated_at is null or old_mst.updated_at is null; <- 이 쿼리로 대체가능
