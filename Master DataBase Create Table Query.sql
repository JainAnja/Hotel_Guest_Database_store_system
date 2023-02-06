Use Team_1_Project_new;


CREATE TABLE AddressDetails
	( 
	AddressID int NOT NULL PRIMARY KEY , 
	ApartmentNumber int  NOT NULL ,
	Street Varchar(40) NOT NULL ,
	City Varchar(15) NOT NULL,
	State Varchar(20) NOT NULL,
	Zipcode int NOT NULL,
	Country Varchar(20) NOT NULL,
	);


CREATE TABLE Guest
    ( 
    GuestID int NOT NULL PRIMARY KEY , 
    GuestNameFName VarChar(40)   NOT NULL ,
	GuestNameLName VarChar(40)  NOT NULL ,
	GuestType VarChar(40)   NOT NULL ,
	ContactNumber Int NOT NULL ,
	AddressID int Foreign KEY REFERENCES AddressDetails 
	 ) ;	
	 
 CREATE TABLE Reservation
	(
	ReservationID int NOT NULL PRIMARY KEY,
	GuestId int FOREIGN KEY 
	REFERENCES Guest(GuestId),
	RoomNumber int NOT NULL,
	CheckInDate DATE,
	CheckOutDate DATE,
	NumberOfGuest int NOT NULL,
	
	check (CheckInDate <CheckOutDate and CheckinDate< getdate() and NumberOfGuest >= 1 )
	);


Go		 
CREATE TRIGGER fromdate
ON dbo.Reservation 
For update
not for replication
AS BEGIN
Update Bill 
set FromDate = CheckInDate
from dbo.Reservation
END;
Go

Go		 
CREATE TRIGGER todate
ON dbo.Reservation 
For update
not for replication
AS BEGIN
Update Bill 
set ToDate = CheckOutDate
from dbo.Reservation
END;
Go

CREATE TABLE RoomType
    ( 
    RoomType VarChar(20) NOT NULL PRIMARY KEY , 
	NumberOfBeds int NOT NULL,
    IsWifiAvailable VarChar(5) NOT NULL ,
	IsRefridgeratorAvailable VarChar(5) NOT NULL ,
	IsACAvailable VarChar(5) NOT NULL ,
	FoodAvailability VarChar(5) NOT NULL ,
	IsTelevisionAvailable VarChar(5) NOT NULL ,
	IsIPTVAvailable VarChar(5) NOT NULL ,
	Rent Int NOT NULL
	 ) ;



CREATE TABLE Room
	(
	RoomNumber int NOT NULL Primary Key,
	RoomType VarChar(20) references RoomType(RoomType),
	IsReserved varchar(5) not null
	);



CREATE TABLE Feedback
	(
	FeedBackID int NOT NULL PRIMARY KEY,
	GuestID int FOREIGN KEY REFERENCES Guest(GuestID),
	FeedbackDescription VarChar(40) NOT NULL, 
	FeedBackDate DATE
	);


CREATE TABLE FoodPreference
(
ReservationId int PRIMARY KEY FOREIGN KEY 
REFERENCES Reservation(ReservationID),
FoodType VARCHAR(40)
);

go
create function roomRent
(@roomType varchar(20))
returns int
As
Begin 
Declare @rent int;
select @rent = isnull( Rent , 0)
from RoomType
where RoomType = @roomType
return @rent;
End;
go



 Create Table Bill
	(
	BillID int not null primary key,
	ReservationID int references Reservation(ReservationID),
	RoomType VarChar(20) references RoomType(RoomType),
	FromDate date not null,
	ToDate date not null,
	BarCharge int,
	GymCharge int,
	PickupAndDropCharge int,
	TotalAmount as ((DATEDIFF(d, FromDate, ToDate) * dbo.roomRent(RoomType)) + BarCharge + GymCharge + PickupAndDropCharge)
	);

	

 Create table Payment
	(
	PaymentID int not null primary key,
	BillID int Foreign key references Bill(BillID),
	PaymentType varchar(20) not null,
	PaymentDate date not null
	);



CREATE TABLE IPLTeam
    ( 
	IPLteam int NOT NULL PRIMARY KEY , 
	GuestId int Foreign KEY REFERENCES Guest(GuestId),
	ExtraAmenities Varchar(40)
	) ;


CREATE TABLE GymUsage
    ( 
    ReservationID int NOT NULL primary key,
    InTime time  NOT NULL ,
	OutTime time NOT NULL ,
	FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
	 ) ;

 CREATE TABLE PickupAndDropService
    ( 
    ReservationID int NOT NULL primary key,
    PickupTime Date  NOT NULL ,
	DropTime Date NOT NULL ,
	FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID)
	) ;
	

CREATE TABLE BarUsage
	(
	ReservationID int NOT NULL PRIMARY KEY FOREIGN KEY REFERENCES Reservation(ReservationID),
	PackageName Varchar(40) NOT NULL,
	Charge int NOT NULL,
	);


CREATE TABLE MatchSchedule 
	( 
	MatchNumber int NOT NULL PRIMARY KEY ,
	MatchDateandTime DATE ,
	PracticeDateandTime DATE ,
	Team1 Varchar(40),
	Team2 Varchar(40)
	 ) ;

create function ufCheckpayment (@GuestID int)
returns money
begin
   declare @amt money;
   select @amt = Totalamount
      from Bill
      where GuestID = @GuestID and PaymentDate is null;
   return @amt;
end ;
alter table  Reservation  add CONSTRAINT ckpaymnet CHECK (dbo.ufCheckpayment (GuestID) = 
0) ;
