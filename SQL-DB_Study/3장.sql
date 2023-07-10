-- shopdb 생성
CREATE TABLE `shopdb`.`membertbl` (
  `memberID` CHAR(8) NOT NULL,
  `memberName` CHAR(5) NOT NULL,
  `memberAddress` CHAR(20) NULL,
  PRIMARY KEY (`memberID`));
CREATE TABLE `shopdb`.`producttbl` (
  `productName` CHAR(4) NOT NULL,
  `cost` INT NOT NULL,
  `makeDate` DATE NULL,
  `company` CHAR(5) NULL,
  `amount` INT NOT NULL,
  PRIMARY KEY (`productName`));

-- 데이터
INSERT INTO `shopdb`.`membertbl` (`memberID`, `memberName`, `memberAddress`) VALUES ('Dang', '당탕이', '경기 부천시 중동');
INSERT INTO `shopdb`.`membertbl` (`memberID`, `memberName`, `memberAddress`) VALUES ('Jee', '지운이', '서울 은평구 증산동');
INSERT INTO `shopdb`.`membertbl` (`memberID`, `memberName`, `memberAddress`) VALUES ('Han', '한주연', '인천 남구 주안동');
INSERT INTO `shopdb`.`membertbl` (`memberID`, `memberName`, `memberAddress`) VALUES ('Sang', '상길이', '경기 성남시 분당구');
INSERT INTO `shopdb`.`producttbl` (`productName`, `cost`, `makeDate`, `company`, `amount`) VALUES ('컴퓨터', '10', '2021-01-01', '삼성', '17');
INSERT INTO `shopdb`.`producttbl` (`productName`, `cost`, `makeDate`, `company`, `amount`) VALUES ('세탁기', '20', '2022-09-01', 'LG', '3');
INSERT INTO `shopdb`.`producttbl` (`productName`, `cost`, `makeDate`, `company`, `amount`) VALUES ('냉장고', '5', '2023-02-01', '대우', '22');

-- 3.3.1 인덱스
create table indexTBL (first_name varchar(14), last_name varchar(16), hire_date date); -- 인덱스 테이블 생성
insert into indexTBL
    select first_name, last_name, hire_date
    from employees.employees
    limit 500;
select * from indextbl;
select * from indexTBL where first_name = 'Mary'; -- Full Table Scan

create index idx_indexTBL_firstname ON indexTBL(first_name); -- 인덱스 생성
select * from indexTBL where first_name = 'Mary'; -- Non-Unique Key Lookup


-- 3.3.2 뷰
create view uv_memberTBL
as select memberName, memberAddress from memberTBL;
select * from uv_memberTBL; -- 뷰이지만 테이블처럼 보임


-- 3.3.3 스토어드 프로시저
delimiter //
create procedure myProc()
begin
    select * from membertbl where membername="당탕이";
    select * from producttbl where productname="냉장고";
end //
delimiter;

call myProc();
drop procedure myProc;


-- 3.3.4 트리거
insert into membertbl values('Figure','연아','경기도 군포시 당정동');
select * from membertbl; -- 데이터확인
update membertbl set memberAddress='서울 강남구 역삼동' where membername='연아'; -- 주소데이터변경
delete from membertbl where memberName='연아';

-- 지워진 데이터를 보관할 테이블 생성
create table deletedmembertbl( 
memberID CHAR(8),
memberName CHAR(5),
memberAddress CHAR(20),
deletedDate DATE -- 삭제한날짜
);

select * from deletedmembertbl;

delimiter //
create trigger trg_deletedmembertbl -- 트리거 이름
	after delete -- 삭제 후에 작동하게 지정
	on membertbl -- 트리거를 부착할 테이블
	for each row -- 각 행마다 적용시킴
begin
insert into deletedmembertbl values (OLD.memberID, OLD.memberName, OLD.memberAddress, CURDATE() ); -- OLD 테이블의 내용을 백업 테이블에 삽입
end //
delimiter;

-- 트리거 확인해보기
select * from membertbl;
delete from membertbl where membername = '당탕이'; -- 데이터삭제
select * from membertbl; -- 원래 테이블에서 데이터 삭제 확인
select * from deletedmembertbl; -- 백업테이블확인 check backup-table