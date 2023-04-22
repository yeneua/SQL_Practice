-- 18-4. 특정 IP 주소에서의 접근 제외하기

-- 예약 ip 주소를 정의한 마스터 테이블
WITH
mst_reserved_ip as (
            select '127.0.0.0/8' as network, 'localhost' as description
  union all select '10.0.0.0/8' as network, 'private network' as description
  union all select '172.16.0.0/12' as network, 'private network' as description
  union all select '192.0.0.0/24' as network, 'private network' as description
  union all select '192.168.0.0/16' as network, 'private network' as description
  
)
select *
from mst_reserved_ip;


-- inet 자료형을 사용해 ip 주소를 판정하는 쿼리
WITH
mst_reserved_ip as (
            select '127.0.0.0/8' as network, 'localhost' as description
  union all select '10.0.0.0/8' as network, 'private network' as description
  union all select '172.16.0.0/12' as network, 'private network' as description
  union all select '192.0.0.0/24' as network, 'private network' as description
  union all select '192.168.0.0/16' as network, 'private network' as description
  
),
action_log_with_reserved_ip as (
    select
        l.user_id,
        l.ip,
        l.stamp,
        m.network,
        m.description
    from action_log_with_ip as l
        left join mst_reserved_ip m on l.ip::inet << m.network::inet -- l.ip가 m.network에 포함되는지 판별
)
select * from action_log_with_reserved_ip;


-- 예약 ip 주소의 로그를 제외하는 쿼리
WITH
mst_reserved_ip as (
            select '127.0.0.0/8' as network, 'localhost' as description
  union all select '10.0.0.0/8' as network, 'private network' as description
  union all select '172.16.0.0/12' as network, 'private network' as description
  union all select '192.0.0.0/24' as network, 'private network' as description
  union all select '192.168.0.0/16' as network, 'private network' as description
  
),
action_log_with_reserved_ip as (
    select
        l.user_id,
        l.ip,
        l.stamp,
        m.network,
        m.description
    from action_log_with_ip as l
        left join mst_reserved_ip m on l.ip::inet << m.network::inet
)
select *
from action_log_with_reserved_ip
where network is null;



-- 네트워크 범위를 나타내는 처음과 끝 ip주소를 부여하는 쿼리
WITH
mst_reserved_ip_with_range as ( -- 마스터 테이블에 네트워크 범위에 해당하는 ip주소의 최솟값과 최댓값 추가하기
  select '127.0.0.0/8' as network
      , '127.0.0.0' as network_start_ip
      , '127.255.255.255' as network_last_ip
      , 'localhost' as description
  union all
   select '172.16.0.0/12' as network
      , '172.16.0.0' as network_start_ip
      , '172.31.255.255' as network_last_ip
      , 'private network' as description
  union all
   select '192.0.0.0/24' as network
      , '192.0.0.0' as network_start_ip
      , '192.0.0.255' as network_last_ip
      , 'private network' as description
  union all
   select '192.168.0.0/16' as network
      , '192.168.0.0' as network_start_ip
      , '192.168.255.255' as network_last_ip
      , 'private network' as description
  union all
   select '10.0.0.0/8' as network
      , '10.0.0.0' as network_start_ip
      , '10.255.255.255' as network_last_ip
      , 'private network' as description
)
select *
from mst_reserved_ip_with_range;

-- ip주소를 0으로 메운 문자열로 변환하고, 특정 ip 로그를 배제하는 쿼리
WITH
mst_reserved_ip_with_range as (
  select '127.0.0.0/8' as network
      , '127.0.0.0' as network_start_ip
      , '127.255.255.255' as network_last_ip
      , 'localhost' as description
  union all
   select '172.16.0.0/12' as network
      , '172.16.0.0' as network_start_ip
      , '172.31.255.255' as network_last_ip
      , 'private network' as description
  union all
   select '192.0.0.0/24' as network
      , '192.0.0.0' as network_start_ip
      , '192.0.0.255' as network_last_ip
      , 'private network' as description
  union all
   select '192.168.0.0/16' as network
      , '192.168.0.0' as network_start_ip
      , '192.168.255.255' as network_last_ip
      , 'private network' as description
  union all
   select '10.0.0.0/8' as network
      , '10.0.0.0' as network_start_ip
      , '10.255.255.255' as network_last_ip
      , 'private network' as description
),
action_log_with_ip_varchar as (
    select *,
           lpad(split_part(ip,'.',1),3,'0')
           || lpad(split_part(ip,'.',2),3,'0')
           || lpad(split_part(ip,'.',3),3,'0')
           || lpad(split_part(ip,'.',4),3,'0') as ip_varchar
    from action_log_with_ip
),
mst_reserved_ip_with_varchar_range as (
    select *,
	lpad(split_part(network_start_ip,'.',1),3,'0')
           || lpad(split_part(network_start_ip,'.',2),3,'0')
           || lpad(split_part(network_start_ip,'.',3),3,'0')
           || lpad(split_part(network_start_ip,'.',4),4,'0') as network_start_ip_varchar,
           lpad(split_part(network_last_ip,'.',1),3,'0')
           || lpad(split_part(network_last_ip,'.',2),3,'0')
           || lpad(split_part(network_last_ip,'.',3),3,'0')
           || lpad(split_part(network_last_ip,'.',4),4,'0') as network_last_ip_varchar
    from mst_reserved_ip_with_range
)
select l.user_id, l.ip,l.ip_varchar,l.stamp
from action_log_with_ip_varchar as l
cross join mst_reserved_ip_with_varchar_range as m
group by l.user_id,l.ip,l.ip_varchar,l.stamp
having sum(case when l.ip_varchar between m.network_start_ip_varchar and m.network_last_ip_varchar then 1 else 0 end) = 0;