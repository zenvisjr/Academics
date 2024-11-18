#describe report;
#describe orderDetails;

create table report (
UserID int,
UserName varchar(100),
Result varchar(5)
);

insert into report(UserID, UserName) select `User ID`, Name  from userDetails;
#select * from userDetails;
#select * from report;
#select * from orderDetails;
#select * from brandDetails;


alter table orderDetails modify column `Order Date` date;

create table rank_date (
sellerID int,
brandID int,
date_rank int
);

insert into rank_date(sellerID, brandID, date_rank) 
select `Seller ID`, `Brand ID`, 
rank() over (partition by `Seller ID` order by `Order Date`) as date_rank 
from orderDetails;

#select * from rank_date;

update report set Result = 'Yes' where UserID in (select `User ID` 
from (rank_date inner join brandDetails on rank_date.`brandID` = brandDetails.`Brand ID` and date_rank = 2) 
inner join userDetails on rank_date.`sellerID` = userDetails.`User ID` 
where `Laptop Brand` = `Favorite Laptop Brand`);

update report set Result = 'No' where UserID in (select `Seller ID` from orderDetails group by `Seller ID` having count(`Seller ID`)<3);

update report set Result = 'No' where Result is null;
#update report set Result = null;