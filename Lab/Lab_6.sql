-- 1. Setup: Create and Use Database
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Netflix_RedAlgorithm')
    DROP DATABASE Netflix_RedAlgorithm;
GO
CREATE DATABASE Netflix_RedAlgorithm;
GO
USE Netflix_RedAlgorithm;
GO

-- 2. Create Tables
-- Regions: Different global markets
CREATE TABLE Regions (
    RegionID INT IDENTITY(1,1) PRIMARY KEY,
    RegionName NVARCHAR(100) NOT NULL,
    CountryCode CHAR(2) UNIQUE
);

-- Studios: Content creators/owners
CREATE TABLE Studios (
    StudioID INT IDENTITY(1,1) PRIMARY KEY,
    StudioName NVARCHAR(100) NOT NULL,
    HeadOfProduction NVARCHAR(100)
);

-- Movies: Core content metadata
CREATE TABLE Movies (
    MovieID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Genre NVARCHAR(50),
    ReleaseYear INT,
    Rating DECIMAL(2,1) CHECK (Rating BETWEEN 0 AND 5),
    StudioID INT FOREIGN KEY REFERENCES Studios(StudioID) ON DELETE SET NULL
);

-- Regional_Availability: Tracks where movies are available and their views
CREATE TABLE Regional_Availability (
    AvailabilityID INT IDENTITY(1,1) PRIMARY KEY,
    MovieID INT FOREIGN KEY REFERENCES Movies(MovieID) ON DELETE CASCADE,
    RegionID INT FOREIGN KEY REFERENCES Regions(RegionID) ON DELETE CASCADE,
    ViewCount BIGINT DEFAULT 0,
    ExpiryDate DATE -- For licensing lab tasks
);

-- Subscribers: User data for performance and security labs
CREATE TABLE Subscribers (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(100),
    YearsSubscribed INT DEFAULT 0,
    MembershipLevel NVARCHAR(20) DEFAULT 'Bronze',
    LastLoginRegionID INT FOREIGN KEY REFERENCES Regions(RegionID)
);

-- Security_Flags: For logging suspicious activity
CREATE TABLE Security_Flags (
    FlagID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT,
    FlagReason NVARCHAR(MAX),
    FlagDate DATETIME DEFAULT GETDATE()
);
GO

-- 3. Insert Sample Data
INSERT INTO Regions (RegionName, CountryCode) VALUES
('North America', 'US'), ('Europe', 'UK'), ('Asia', 'JP'), ('South America', 'BR');

INSERT INTO Studios (StudioName, HeadOfProduction) VALUES
('Netflix Originals', 'Scott Stuber'), ('Warner Bros', 'Michael De Luca'), ('A24', 'Daniel Katz');

INSERT INTO Movies (Title, Genre, ReleaseYear, Rating, StudioID) VALUES
('Stranger Things: The Movie', 'Sci-Fi', 2024, 4.9, 1),
('The Dark Knight', 'Action', 2008, 5.0, 2),
('Everything Everywhere All At Once', 'Sci-Fi', 2022, 4.8, 3),
('Squid Game: Feature', 'Thriller', 2023, 4.2, 1),
('Old Classic', 'Drama', 1995, 3.1, 2);

INSERT INTO Regional_Availability (MovieID, RegionID, ViewCount, ExpiryDate) VALUES
(1, 1, 1500000, '2030-01-01'), -- Stranger Things in US
(1, 3, 1200000, '2030-01-01'), -- Stranger Things in JP
(2, 1, 900000, '2025-04-15'),  -- Dark Knight in US (Expiring soon)
(4, 3, 2000000, '2026-06-01'), -- Squid Game in JP
(5, 2, 500, '2025-03-20');      -- Old Classic in UK (Low views)

INSERT INTO Subscribers (Email, YearsSubscribed, MembershipLevel, LastLoginRegionID) VALUES
('user1@example.com', 6, 'Bronze', 1),
('user2@example.com', 3, 'Bronze', 2),
('user3@example.com', 1, 'Bronze', 3);
GO

--1
create view v_PopularMoviesByRegion as
select Movies.MovieID, Movies.Title, Movies.Genre, Regional_Availability.RegionID, Regional_Availability.ViewCount
from Movies join Regional_Availability on Movies.MovieID=Regional_Availability.MovieID
where Regional_Availability.ViewCount>1000000
GO

--2
create view v_ExpiringContent as
select Movies.MovieID, Movies.Title, Regional_Availability.ExpiryDate, Regions.RegionName
from Movies join Regional_Availability on Movies.MovieID=Regional_Availability.MovieID join Regions on Regional_Availability.RegionID=Regions.RegionID
where getdate()+30>Regional_Availability.ExpiryDate
GO

--3
create view v_TopDirectors as
select Studios.StudioID, Studios.HeadOfProduction, count(*) as TotalMovies
from Movies join Studios on Movies.StudioID=Studios.StudioID
group by Studios.HeadOfProduction, Studios.StudioID
having avg(Movies.Rating)>4.5
GO

--4

--5
create procedure usp_GetTopMoviesByCountry
@countryname NVARCHAR(100)
as
begin
select Regional_Availability.MovieID, Movies.Title
from Regional_Availability join Regions on Regional_Availability.RegionID=Regions.RegionID join Movies on Movies.MovieID=Regional_Availability.MovieID
where Movies.Rating=5 and Regions.RegionName=@countryname
end
go

exec usp_GetTopMoviesByCountry @countryname='North America'
GO

--6
CREATE PROCEDURE usp_PromoteSubscribers
@UserID INT
AS
BEGIN
IF (SELECT YearsSubscribed FROM Subscribers WHERE UserID=@UserID) > 5
BEGIN
  UPDATE Subscribers
  SET MembershipLevel='Gold'
  WHERE UserID=@UserID
END
ELSE IF (SELECT YearsSubscribed FROM Subscribers WHERE UserID=@UserID) > 2
BEGIN
  UPDATE Subscribers
  SET MembershipLevel='Silver'
  WHERE UserID=@UserID
END
ELSE
BEGIN
  UPDATE Subscribers
  SET MembershipLevel='Bronze'
  WHERE UserID=@UserID
END
END
GO

--7
create procedure usp_AssignMovieToRegion
@movieid int, @regionid int as
begin
if exists(select * from Regional_Availability where RegionID=@regionid and MovieID=@movieid)
begin
print 'Content already located'
return
end
insert into Regional_Availability values (@regionid, @movieid, 0, convert(date, getdate()))
end
go
exec usp_AssignMovieToRegion @movieid=1, @regionid=1

--8
create table archived_content(
  MovieID INT PRIMARY KEY,
  Title NVARCHAR(200) NOT NULL,
  Genre NVARCHAR(50),
);
go 

create procedure usp_ArchiveLowPerformers
as 
begin 
insert into archived_content
select * 
from Movies join Regional_Availability on Movies.MovieID=Regional_Availability.MovieID
where Movies.ReleaseYear+2>year(getdate()) and Regional_Availability.ViewCount<1000
delete from Movies
where Movies.ReleaseYear+2>year(getdate()) and Regional_Availability.ViewCount<1000
end
go 

--9
--there is no history tracking for login details