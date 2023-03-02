-- 5-5. 결손값을 디폴트 값으로 대치하기
select purchase_id, amount, coupon, amount - coupon AS disount_amount1, amount - COALESCE(coupon, 0) AS discount_amount2
from `data.purchase_log_with_coupon`;