-- 5-3. 문자열을 배열로 분해하기

-- 페이지 계층 나누기
select url, regexp_extract(url, '//[^/]+([^?#]+)') AS path0,
              split(regexp_extract(url, '//[^/]+([^?#]+)'), '/')[SAFE_ORDINAL(0)] AS SAFE_ORDINAL_0,
              split(regexp_extract(url, '//[^/]+([^?#]+)'), '/')[SAFE_ORDINAL(1)] AS SAFE_ORDINAL_1,
              split(regexp_extract(url, '//[^/]+([^?#]+)'), '/')[SAFE_ORDINAL(2)] AS SAFE_ORDINAL_2,
              split(regexp_extract(url, '//[^/]+([^?#]+)'), '/')[SAFE_OFFSET(0)] AS SAFE_OFFSET_0,
              split(regexp_extract(url, '//[^/]+([^?#]+)'), '/')[SAFE_OFFSET(1)] AS SAFE_OFFSET_1,
              split(regexp_extract(url, '//[^/]+([^?#]+)'), '/')[SAFE_OFFSET(2)] AS SAFE_OFFSET_2
from `data.access_log`;

-- ordinal은 인덱스가 1부터 시작(배열)
-- offset은 인덱스가 0부터 시작(배열)
-- 배열 길이 이상으로 접근하면 에러나기 때문에 safe_ordinal, safe_offset으로 접근 - null값 반환함