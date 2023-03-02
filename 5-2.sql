-- 5-2.URL에서 요소 추출하기

-- 레퍼러로 어떤 페이지에서 거쳐 넘어왔는지 판별

select stamp,net.host(referrer) AS referrer_host
from `data.access_log`;

select count(stamp) AS dcount, net.host(referrer) AS referrer_host
from `data.access_log`
group by net.host(referrer)

-- url에서 경로와 요청 매개변수값 추출
-- select stamp, url, regexp_extract(url, '//[^/]+([^?#]+)') AS path, regexp_extract(url, 'id=([^&]*)') AS id
-- from `data.access_log`;