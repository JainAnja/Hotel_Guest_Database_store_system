Use Team_1_Project_new;

ALTER TABLE Guest
ADD FOREIGN KEY (AddressID) REFERENCES AddressDetails(AddressID);

ALTER TABLE Reservation
ADD FOREIGN KEY (GuestId) REFERENCES Guest(GuestId);

Go
create function Guestcount ()
returns Int
as
begin
   declare @NumCount int;
   Select @NumCount = Count(*)
   from Reservation
   where NumberOfGuests <1;
   return @NumCount ;
end ;
go

ALTER TABLE Reservation
ADD CONSTRAINT CheckData1
check (dbo.Guestcount() <1);

ALTER TABLE Reservation
ADD
check (CheckInDate <CheckOutDate and CheckinDate< getdate() and NumberOfGuests >= 1 );

ALTER TABLE Feedback
ADD FOREIGN KEY (GuestId) REFERENCES Guest(GuestId);

ALTER TABLE FoodPreference
ADD FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID);


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

ALTER TABLE Bill
ADD FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID);

Alter table Bill 	
add TotalAmount as ((DATEDIFF(d, FromDate, ToDate) * dbo.roomRent(RoomType)) + BarCharge + GymCharge + PickupAndDropCharge)


ALTER TABLE Payment
ADD FOREIGN KEY (BillID) REFERENCES Bill(BillID);
 

ALTER TABLE IPLTeam
ADD FOREIGN KEY (GuestId) REFERENCES Guest(GuestId);

ALTER TABLE GymUsage
ADD FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID);

ALTER TABLE PickupAndDropService
ADD FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID);

ALTER TABLE BarUsage
ADD FOREIGN KEY (ReservationID) REFERENCES Reservation(ReservationID);


create view Guest.ContactNumber
as
select GuestFName, GuestLName, ContactNumber
from Guest;
Select * from guest;
select * from Guest.ContactNumber;

create view Guest.RoomNumber
as
select GuestFName, GuestLName, RoomNumber
from Guest G
left join Reservation R on 
G.GuestID = R.GuestId;

select * from Guest.RoomNumber;