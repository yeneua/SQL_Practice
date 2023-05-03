-- 22-1. 데이터 마이닝

-- 구매 로그 수와 상품별 구매 수를 세는 쿼리
with
purchase_id_count as (
	select count(distinct purchase_id) as purchase_count -- 유니크한 구매 로그 수
	from purchase_detail_log
)
, purchase_detail_log_with_counts as (
	select d.purchase_id, p.purchase_count, d.product_id,
		   count(1) over(partition by d.product_id) as product_count -- product_id별로 count(1)
	from purchase_detail_log as d
		cross join purchase_id_count as p -- cross join : 모든 행 조인(상호조인)
)
select *
from purchase_detail_log_with_counts
order by purchase_id,product_id;


-- 상품 조합별로 구매 수를 세는 쿼리
with
purchase_id_count as (
	select count(distinct purchase_id) as purchase_count
	from purchase_detail_log
),
purchase_detail_log_with_counts as (
	select d.purchase_id, p.purchase_count, d.product_id,
		   count(1) over(partition by d.product_id) as product_count
	from purchase_detail_log as d
		cross join purchase_id_count as p
),
product_pair_with_stat as (
	select l1.product_id as p1,
		   l2.product_id as p2,
		   l1.product_count as p1_count,
		   l2.product_count as p2_count,
		   count(1) as p1_p2_count, -- purchase_id별로 동시 구매 수 계산
		   l1.purchase_count as purchase_count -- 구매 총 로그 수
	from purchase_detail_log_with_counts as l1
		join purchase_detail_log_with_counts as l2
		on l1.purchase_id = l2.purchase_id -- 같은 구매 ID로 셀프 조인
	where l1.product_id <> l2.product_id -- 같은 상품 조합 제외하기
	group by l1.product_id, l2.product_id, l1.product_count, l2.product_count, l1.purchase_count
)
select *
from product_pair_with_stat
order by p1, p2;


-- 지지도, 확산도, 리프트를 계산하는 쿼리
with
purchase_id_count as (
	select count(distinct purchase_id) as purchase_count
	from purchase_detail_log
),
purchase_detail_log_with_counts as (
	select d.purchase_id, p.purchase_count, d.product_id,
		   count(1) over(partition by d.product_id) as product_count
	from purchase_detail_log as d
		cross join purchase_id_count as p
),
product_pair_with_stat as (
	select l1.product_id as p1,
		   l2.product_id as p2,
		   l1.product_count as p1_count,
		   l2.product_count as p2_count,
		   count(1) as p1_p2_count,
		   l1.purchase_count as purchase_count
	from purchase_detail_log_with_counts as l1
		join purchase_detail_log_with_counts as l2
		on l1.purchase_id = l2.purchase_id
	where l1.product_id <> l2.product_id
	group by l1.product_id, l2.product_id, l1.product_count, l2.product_count, l1.purchase_count
)
select p1, p2,
       100.0 * p1_p2_count / purchase_count as support, -- 지지도 : 상관규칙이 어느 정도 확률로 발생하는지 -> A구매&B구매 / 전체
       100.0 * p1_p2_count / p1_count as confidence, -- 확신도/신뢰도 : 어떤 결과가 어느 정도의 확류롤 발생하는지를 의미하는 값 -> A구매&Y구매 / A구매
       (100.0 * p1_p2_count / p1_count) / (100.0 * p2_count / purchase_count) as lift -- 리프트 : 어떤 조건을 만족하는 경우의 확률(확신도)을 사전 조건 없이 해당 결과가 일어날 확률로 나눈 값 -> 확신도 / (B구매 / 전체)
from product_pair_with_stat
order by p1, p2;