-- 6-6. IP 주소 다루기

-- 정수 또는 문자열로 ip다루기
-- 1. ip주소를 정수 자료형으로 반환하기
select ip, cast(split(ip,'.')[safe_ordinal(1)] as int64) as ip_part_1,
           cast(split(ip,'.')[safe_ordinal(2)] as int64) as ip_part_2,
           cast(split(ip,'.')[safe_ordinal(3)] as int64) as ip_part_3,
           cast(split(ip,'.')[safe_ordinal(4)] as int64) as ip_part_4
from (select '192.168.0.1' as ip) as t;

-- 2.ip주소를 정수 자료형 표기로 변환하는 쿼리
select ip, cast(split(ip,'.')[safe_ordinal(1)] as int64) * pow(2,24)   -- pow(a,b)a^b
          +cast(split(ip,'.')[safe_ordinal(2)] as int64)*pow(2,16)
          +cast(split(ip,'.')[safe_ordinal(3)] as int64)*pow(2,8)
          +cast(split(ip,'.')[safe_ordinal(4)] as int64)*pow(2,0) as ip_integer
from (select '192.168.0.1' as ip) as zz;

-- 3.ip주소를 0으로 메우기
select ip, concat(lpad(split(ip,'.')[safe_ordinal(1)],3,'0'),--lapd(original_value,return_length[,pattern])
                  lpad(split(ip,'.')[safe_ordinal(2)],3,'0'),
                  lpad(split(ip,'.')[safe_ordinal(3)],3,'0'),
                  lpad(split(ip,'.')[safe_ordinal(4)],3,'0')) as ip_padding
from (select '192.168.0.1' as ip) as z;


