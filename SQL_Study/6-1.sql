-- 6-1.문자열 연결하기

select string_field_0, concat(string_field_1, string_field_2) as pref_city, concat(string_field_0,"  ",string_field_1,string_field_2) as name
from data.mst_user_location;