-- 6-4. 두 값의 거리 계산하기

-- 데이터분석에서는 물리적공간의 길이가 아닌 거리라는 개념이 많이 등장

-- 숫자데이터의절댓값,제곱평균제곱근(RMS)계산하기
-- power():제곱  power(x1,3) x1을 세제곱
-- sqrt():제곱근
-- abs():절대값

select abs(x1-x2) as abs, sqrt(power(x1-x2,2)) as rms
from `ivory-program-349520.data.location_1d`;


-- xy평면 위에 있는 두점의 유클리드거리 계산하기
select sqrt(power(x1-x2,2) +power(y1-y2,2)) as dist
from `ivory-program-349520.data.location_2d`;