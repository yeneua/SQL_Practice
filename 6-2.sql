-- 6-2. 여러개의 값 비교하기
-- 분기별 매출 증감 판정하기
select year, q1, q2, case when q1 < q2 then '+'
                          when q1 = q2 then ' '
                          else '-'
                     end AS judge_q1_q1,
       q2 - q1 as diff_q2_q1, sign(q2-q1) as sign_q2_q1
from `ivory-program-349520.data.quarterly_sales`
order by year;
-- sign() : 매개변수가 양수면1, 0이면0, 음수면-1리턴

-- 연간 최대/최소 4분기 매출 찾기
select year, greatest(q1,q2,q3,q4) as greatest_sales, least(q1,q2,q3,q4) as least_sales
from `ivory-program-349520.data.quarterly_sales`;

-- 연간 평균 4분기 매출 계산하기
select year, (q1+q2+q3+q4)/4 as average
from `ivory-program-349520.data.quarterly_sales`
order by year;

select year,(coalesce(q1,0)+coalesce(q2,0)+coalesce(q3,0)+coalesce(q4,0))/4 as average  --null값 0으로 대체
from `ivory-program-349520.data.quarterly_sales`
order by year;

select year,(coalesce(q1,0)+coalesce(q2,0)+coalesce(q3,0)+coalesce(q4,0))/(sign(coalesce(q1,0))+sign(coalesce(q2,0))+sign(coalesce(q3,0))+sign(coalesce(q4,0))) as average --나누는 칼럼 수를 sign함수를 이용해서 구하기
from `ivory-program-349520.data.quarterly_sales`
order by year;



