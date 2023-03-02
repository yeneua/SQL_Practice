-- 5-1. 코드값을 레이블로 분해하기

select user_id,
      case when register_device = 1 then '데스크톱'
           when register_device = 2 then '스마트폰'
           when register_device = 3 then '애플리케이션'
      end as device_name
from `data.mst_users`;