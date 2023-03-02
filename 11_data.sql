drop table if exists ivory-program-349520.data.mst_users;

create table ivory-program-349520.data.mst_users(
  user_id string(255),
  sex string(255),
  birth_date date,
  register_daste date,
  register_device string(255),
  withdraw_date date
);

insert into ivory-program-349520.data.mst_users
values
    ('U001', 'M', '1977-06-17', '2016-10-01', 'pc', null),
    ('U002', 'F', '1953-06-12', '2016-10-01', 'sp', '2016-10-10'),
    ('U003', 'M', '1965-01-06', '2016-10-01', 'pc', null),
    ('U004', 'F', '1954-05-21', '2016-10-05', 'pc', null),
    ('U005', 'M', '1987-11-23', '2016-10-05', 'sp', null),
    ('U006', 'F', '1950-01-21', '2016-10-10', 'pc', '2016-10-10'),
    ('U007', 'F', '1950-07-18', '2016-10-10', 'app', null),
    ('U008', 'F', '2006-12-09', '2016-10-10', 'sp', null),
    ('U009', 'M', '2004-10-23', '2016-10-15', 'pc', null),
    ('U010', 'F', '1987-03-18', '2016-10-16', 'pc', null)
;