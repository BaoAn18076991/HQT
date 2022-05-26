use AdventureWorks2016

create table MCustomer
(
	CustomerID int not null primary key, 
	CustPriority int
)
create table MSalesOrders 
(
	SalesOrderID int not null primary key, 
	OrderDate date,
	SubTotal money,
	CustomerID int foreign key references MCustomer(CustomerID)
)


INSERT into [dbo].[MCustomer]
	select CustomerID , null
	from [Sales].[Customer]
	where CustomerID>30100 and CustomerID<30118


insert MSalesOrders
	select OH.SalesOrderID,OH.OrderDate,OH.SubTotal,OH.CustomerID
	from [Sales].[SalesOrderHeader] OH where OH.CustomerID in(select MC.CustomerID from [dbo].[MCustomer] MC)


select * from [dbo].[MSalesOrders]


create trigger cau2 on [dbo].[MSalesOrders]
for insert , update, delete
as
begin
	declare @makh int , @tong money
	if exists(select* from inserted)
		begin
			select @makh=CustomerID, @tong=sum(SubTotal)
			from inserted
			group by CustomerID

			update MCustomer
			set CustPriority= case
								when @tong<10000 then 3
								when @tong between 10000 and 50000 then 2
								when @tong >50000 then 1
							end
			where CustomerID=@makh
		end
	if exists(select * from deleted) and not exists(select * from inserted)
		begin
			select @makh=CustomerID from deleted
			update MCustomer
			set CustPriority=Null
			where CustomerID=@makh
		end
end


--Kiem tra
go
insert MSalesOrders values(10000,getdate(),55000,30101)
select * from MSalesOrders
select * from MCustomer
delete from MSalesOrders where SalesOrderID=10000