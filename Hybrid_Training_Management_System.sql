USE [master]
GO
/****** Object:  Database [u_bmarcini]    Script Date: 23.02.2024 15:12:20 ******/
CREATE DATABASE [u_bmarcini]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'u_bmarcini', FILENAME = N'/var/opt/mssql/data/u_bmarcini.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'u_bmarcini_log', FILENAME = N'/var/opt/mssql/data/u_bmarcini_log.ldf' , SIZE = 66048KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [u_bmarcini] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [u_bmarcini].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [u_bmarcini] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [u_bmarcini] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [u_bmarcini] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [u_bmarcini] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [u_bmarcini] SET ARITHABORT OFF 
GO
ALTER DATABASE [u_bmarcini] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [u_bmarcini] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [u_bmarcini] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [u_bmarcini] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [u_bmarcini] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [u_bmarcini] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [u_bmarcini] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [u_bmarcini] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [u_bmarcini] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [u_bmarcini] SET  ENABLE_BROKER 
GO
ALTER DATABASE [u_bmarcini] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [u_bmarcini] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [u_bmarcini] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [u_bmarcini] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [u_bmarcini] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [u_bmarcini] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [u_bmarcini] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [u_bmarcini] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [u_bmarcini] SET  MULTI_USER 
GO
ALTER DATABASE [u_bmarcini] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [u_bmarcini] SET DB_CHAINING OFF 
GO
ALTER DATABASE [u_bmarcini] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [u_bmarcini] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [u_bmarcini] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [u_bmarcini] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [u_bmarcini] SET QUERY_STORE = OFF
GO
USE [u_bmarcini]
GO
/****** Object:  DatabaseRole [WebinarCoordinator]    Script Date: 23.02.2024 15:12:21 ******/
CREATE ROLE [WebinarCoordinator]
GO
/****** Object:  DatabaseRole [Translator]    Script Date: 23.02.2024 15:12:22 ******/
CREATE ROLE [Translator]
GO
/****** Object:  DatabaseRole [SystemAdministrator]    Script Date: 23.02.2024 15:12:22 ******/
CREATE ROLE [SystemAdministrator]
GO
/****** Object:  DatabaseRole [StudyCoordinator]    Script Date: 23.02.2024 15:12:22 ******/
CREATE ROLE [StudyCoordinator]
GO
/****** Object:  DatabaseRole [OfferCoordinator]    Script Date: 23.02.2024 15:12:22 ******/
CREATE ROLE [OfferCoordinator]
GO
/****** Object:  DatabaseRole [Lecturer]    Script Date: 23.02.2024 15:12:22 ******/
CREATE ROLE [Lecturer]
GO
/****** Object:  DatabaseRole [Director]    Script Date: 23.02.2024 15:12:22 ******/
CREATE ROLE [Director]
GO
/****** Object:  DatabaseRole [CourseCoordinator]    Script Date: 23.02.2024 15:12:22 ******/
CREATE ROLE [CourseCoordinator]
GO
/****** Object:  DatabaseRole [Accounting]    Script Date: 23.02.2024 15:12:22 ******/
CREATE ROLE [Accounting]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateOrderTotal]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalculateOrderTotal] (@OrderID INT)
RETURNS MONEY
AS
BEGIN
    RETURN (SELECT SUM(Quantity * Price) FROM Orders WHERE OrderID = @OrderID)
END
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateTotalCourseDuration]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalculateTotalCourseDuration](@CourseID INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT SUM(DATEDIFF(minute, StartTime, EndTime))
            FROM Modules
            WHERE CourseID = @CourseID)
END
GO
/****** Object:  UserDefinedFunction [dbo].[CheckModuleAvailability]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CheckModuleAvailability] (@ModuleID INT)
RETURNS INT
AS
BEGIN
    DECLARE @MaxParticipants INT;
    SELECT @MaxParticipants = MaxParticipants FROM OfflineModules WHERE ModuleID = @ModuleID;
    RETURN @MaxParticipants - (SELECT COUNT(*) FROM ModuleAttendances WHERE ModuleID = @ModuleID)
END
GO
/****** Object:  UserDefinedFunction [dbo].[CheckRoomAvailability]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[CheckRoomAvailability]
(
    @LocationID INT,
    @DesiredDate DATETIME,
    @DesiredStartTime TIME,
    @DesiredEndTime TIME,
    @NumberOfParticipants INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsAvailable BIT = 1;
    DECLARE @LocationCapacity INT;

    SELECT @LocationCapacity = Capacity
    FROM [dbo].[Locations]
    WHERE LocationID = @LocationID;

    IF EXISTS (
        SELECT 1
        FROM [dbo].[OfflineModules] om
        INNER JOIN [dbo].[Modules] m ON om.ModuleID = m.ModuleID
        WHERE om.LocationID = @LocationID
          AND m.Date = CAST(@DesiredDate AS DATE)
          AND (m.StartTime < @DesiredEndTime AND m.EndTime > @DesiredStartTime)
          AND om.MaxParticipants > (@LocationCapacity - @NumberOfParticipants)
    )
    BEGIN
        SET @IsAvailable = 0;
    END

    IF EXISTS (
        SELECT 1
        FROM [dbo].[OfflineStudyMeetings] osm
        INNER JOIN [dbo].[StudyMeetings] sm ON osm.StudyMeetingID = sm.StudyMeetingID
        WHERE osm.LocationID = @LocationID
          AND sm.Date = CAST(@DesiredDate AS DATE)
          AND (sm.StartTime < @DesiredEndTime AND sm.EndTime > @DesiredStartTime)
          AND osm.MaxParticipants > (@LocationCapacity - @NumberOfParticipants)
    )
    BEGIN
        SET @IsAvailable = 0;
    END

    RETURN @IsAvailable;
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetActiveWebinarsCount]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetActiveWebinarsCount]()
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM WebinarMeetings WHERE ExpirationDate > GETDATE())
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetAverageCoursePrice]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetAverageCoursePrice]()
RETURNS MONEY
AS
BEGIN
    RETURN (SELECT AVG(ProductPrice) FROM Products WHERE ProductType = 'course')
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetAverageReunionPrice]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetAverageReunionPrice]()
RETURNS MONEY
AS
BEGIN
    RETURN (SELECT AVG(ProductPrice) FROM Products WHERE ProductType = 'reunion')
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetAverageWebinarPrice]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetAverageWebinarPrice]()
RETURNS MONEY
AS
BEGIN
    RETURN (SELECT AVG(ProductPrice) FROM Products WHERE ProductType = 'webinar')
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetCourseParticipantCount]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetCourseParticipantCount] (@CourseID INT)
RETURNS INT
AS 
BEGIN
    RETURN (SELECT COUNT(*) FROM CourseParticipants WHERE CourseID = @CourseID)
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetMostPopularCourse]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetMostPopularCourse]()
RETURNS INT
AS
BEGIN
    RETURN (SELECT TOP 1 CourseID FROM CourseParticipants
            GROUP BY CourseID
            ORDER BY COUNT(*) DESC)
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetNumberOfCoursesByLecturer]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetNumberOfCoursesByLecturer](@LecturerID INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) 
            FROM Courses 
            INNER JOIN Modules ON Courses.CourseID = Modules.CourseID
            WHERE Modules.LecturerID = @LecturerID)
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetNumberOfModulesInCourse]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetNumberOfModulesInCourse](@CourseID INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM Modules WHERE CourseID = @CourseID)
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetOrderCountForProduct]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetOrderCountForProduct](@ProductID INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM Orders WHERE ProductID = @ProductID)
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetOverallAverageProductPrice]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetOverallAverageProductPrice]()
RETURNS MONEY
AS
BEGIN
    RETURN (SELECT AVG(ProductPrice) FROM Products)
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetPaymentStatus]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetPaymentStatus](@OrderID INT)
RETURNS BIT
AS
BEGIN
    RETURN (SELECT TOP 1 Status FROM Payments WHERE OrderID = @OrderID ORDER BY PayDate DESC)
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetPendingPaymentsCountByUser]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetPendingPaymentsCountByUser](@UserID INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM Payments
            INNER JOIN Orders ON Payments.OrderID = Orders.OrderID
            WHERE Orders.UserID = @UserID AND Payments.Status = 0)
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetTotalStudentCount]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetTotalStudentCount]()
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM Students)
END
GO
/****** Object:  UserDefinedFunction [dbo].[HasOnlineModules]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[HasOnlineModules](@CourseID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @HasOnline BIT;
    SELECT @HasOnline = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM Modules
    WHERE CourseID = @CourseID AND ModuleType IN ('synchronic online', 'asynchronic online')
    RETURN @HasOnline
END
GO
/****** Object:  UserDefinedFunction [dbo].[HasStudentPassedExam]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[HasStudentPassedExam] (@StudentID INT, @ExamID INT)
RETURNS BIT
AS
BEGIN
    RETURN (SELECT TOP 1 HasPassed FROM ExamResults WHERE StudentID = @StudentID AND ExamID = @ExamID)
END
GO
/****** Object:  UserDefinedFunction [dbo].[HasStudentPendingPayments]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[HasStudentPendingPayments](@StudentID INT)
RETURNS BIT
AS
BEGIN
    RETURN (SELECT CASE WHEN SUM(CASE WHEN Payments.Status = 0 THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END
            FROM Payments 
            INNER JOIN Orders ON Payments.OrderID = Orders.OrderID
            INNER JOIN Students ON Orders.UserID = Students.UserID
            WHERE Students.StudentID = @StudentID)
END
GO
/****** Object:  UserDefinedFunction [dbo].[IsLecturerAvailable]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsLecturerAvailable]
(
    @LecturerID INT,
    @DesiredDate DATETIME,
    @StartTime TIME,
    @EndTime TIME
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsAvailable BIT = 1;

    -- Sprawdzanie dostępności w tabeli Modules
    IF EXISTS (
        SELECT 1
        FROM [dbo].[Modules]
        WHERE LecturerID = @LecturerID
          AND [Date] = CAST(@DesiredDate AS DATE)
          AND ([StartTime] < @EndTime AND [EndTime] > @StartTime)
    )
    BEGIN
        SET @IsAvailable = 0;
    END

    -- Sprawdzanie dostępności w tabeli StudyMeetings
    IF EXISTS (
        SELECT 1
        FROM [dbo].[StudyMeetings]
        WHERE LecturerID = @LecturerID
          AND [Date] = CAST(@DesiredDate AS DATE)
          AND ([StartTime] < @EndTime AND [EndTime] > @StartTime)
    )
    BEGIN
        SET @IsAvailable = 0;
    END

    -- Sprawdzanie dostępności w tabeli WebinarMeetings
    IF EXISTS (
        SELECT 1
        FROM [dbo].[WebinarMeetings]
        WHERE LecturerID = @LecturerID
          AND [Date] = CAST(@DesiredDate AS DATE)
          AND ([StartTime] < @EndTime AND [EndTime] > @StartTime)
    )
    BEGIN
        SET @IsAvailable = 0;
    END

    RETURN @IsAvailable;
END

GO
/****** Object:  UserDefinedFunction [dbo].[IsTranslatorAvailable]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsTranslatorAvailable]
(
    @TranslatorID INT,
    @DesiredDate DATETIME,
    @DesiredStartTime TIME,
    @DesiredEndTime TIME
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsAvailable BIT = 1;

    -- Sprawdzanie dostępności w StudyMeetings
    IF EXISTS (
        SELECT 1 FROM [dbo].[StudyMeetings] sm
        JOIN [dbo].[SubjectsInForeignLanguages] sfl ON sm.SubjectID = sfl.SubjectID
        WHERE sfl.TranslatorID = @TranslatorID
          AND sm.Date = CAST(@DesiredDate AS DATE)
          AND (sm.StartTime < @DesiredEndTime AND sm.EndTime > @DesiredStartTime)
    )
    BEGIN
        SET @IsAvailable = 0;
    END

    -- Sprawdzanie dostępności w WebinarMeetings
    IF EXISTS (
        SELECT 1 FROM [dbo].[WebinarMeetings] wm
        JOIN [dbo].[WebinarsInForeignLanguages] wfl ON wm.WebinarID = wfl.WebinarID
        WHERE wfl.TranslatorID = @TranslatorID
          AND wm.Date = CAST(@DesiredDate AS DATE)
          AND (wm.StartTime < @DesiredEndTime AND wm.EndTime > @DesiredStartTime)
    )
    BEGIN
        SET @IsAvailable = 0;
    END

    -- Sprawdzanie dostępności w Modules
    IF EXISTS (
        SELECT 1 FROM [dbo].[Modules] m
        JOIN [dbo].[ModulesInForeignLanguages] mfl ON m.ModuleID = mfl.ModuleID
        WHERE mfl.TranslatorID = @TranslatorID
          AND m.Date = CAST(@DesiredDate AS DATE)
          AND (m.StartTime < @DesiredEndTime AND m.EndTime > @DesiredStartTime)
    )
    BEGIN
        SET @IsAvailable = 0;
    END

    RETURN @IsAvailable;
END
GO
/****** Object:  UserDefinedFunction [dbo].[IsWebinarRecordingAvailable]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[IsWebinarRecordingAvailable](@WebinarID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Available BIT;
    SELECT @Available = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM WebinarMeetings
    WHERE WebinarID = @WebinarID AND RecordingLink IS NOT NULL AND ExpirationDate > GETDATE()
    RETURN @Available
END
GO
/****** Object:  Table [dbo].[Reunions]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reunions](
	[ReunionID] [int] IDENTITY(1,1) NOT NULL,
	[SemesterID] [int] NULL,
	[ProductID] [int] NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[MaxStudents] [int] NOT NULL,
	[MaxOtherParticipants] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ReunionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Courses]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Courses](
	[CourseID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[CourseName] [nvarchar](50) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[LanguageID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Webinars]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Webinars](
	[WebinarID] [int] IDENTITY(1,1) NOT NULL,
	[WebinarName] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[ProductID] [int] NULL,
	[LanguageID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[WebinarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WebinarMeetings]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WebinarMeetings](
	[WebinarMeetingID] [int] IDENTITY(1,1) NOT NULL,
	[WebinarID] [int] NULL,
	[LecturerID] [int] NULL,
	[Date] [datetime] NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[MeetingLink] [nvarchar](255) NOT NULL,
	[RecordingLink] [nvarchar](255) NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WebinarMeetingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[UserID] [int] NULL,
	[Quantity] [int] NULL,
	[Price] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserType] [nvarchar](30) NOT NULL,
	[FirstName] [nvarchar](30) NOT NULL,
	[LastName] [nvarchar](30) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[RoleID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Payments]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments](
	[PaymentID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NULL,
	[PaymentLink] [nvarchar](255) NOT NULL,
	[Status] [bit] NULL,
	[PayDate] [datetime] NOT NULL,
	[IsDeffered] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductType] [nvarchar](20) NULL,
	[ProductPrice] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Studies]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Studies](
	[StudyID] [int] IDENTITY(1,1) NOT NULL,
	[StudyName] [nvarchar](50) NOT NULL,
	[StudyType] [nvarchar](20) NOT NULL,
	[SemesterCount] [int] NOT NULL,
	[MaxStudents] [int] NOT NULL,
	[LinkToSyllabus] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[StudyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Semesters]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Semesters](
	[SemesterID] [int] IDENTITY(1,1) NOT NULL,
	[StudyID] [int] NULL,
	[SemesterType] [nvarchar](20) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SemesterID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[Debtors]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Debtors] AS 
SELECT 
    Orders.UserID, 
    u.FirstName, 
    u.LastName, 
    w.WebinarName AS EventName, 
    wm.Date AS EventDate,
	p.ProductType
FROM 
    Orders
	INNER JOIN Products p on p.ProductID=Orders.ProductID
    INNER JOIN Payments ON Payments.OrderID = Orders.OrderID
    INNER JOIN Users AS u ON u.UserID = Orders.UserID
    INNER JOIN Webinars w ON w.ProductID = Orders.ProductID
    INNER JOIN WebinarMeetings wm ON wm.WebinarID = w.WebinarID
WHERE 
    Payments.Status = 0 AND 
    wm.Date < GETDATE()

UNION

SELECT 
    Orders.UserID, 
    u.FirstName, 
    u.LastName, 
    c.CourseName AS EventName, 
    c.StartDate AS EventDate,
	p.ProductType
FROM 
    Orders
	INNER JOIN Products p on p.ProductID=Orders.ProductID
    INNER JOIN Payments ON Payments.OrderID = Orders.OrderID
    INNER JOIN Users AS u ON u.UserID = Orders.UserID
    INNER JOIN Courses c ON c.ProductID = Orders.ProductID
WHERE 
    Payments.Status = 0 AND 
    c.EndDate < GETDATE()

UNION

SELECT 
    Orders.UserID, 
    u.FirstName, 
    u.LastName, 
    s.StudyName AS EventName, 
    r.StartDate AS EventDate,
	p.ProductType
FROM 
    Orders
	INNER JOIN Products p on p.ProductID=Orders.ProductID
    INNER JOIN Payments ON Payments.OrderID = Orders.OrderID
    INNER JOIN Users AS u ON u.UserID = Orders.UserID
    INNER JOIN Reunions r ON r.ProductID = Orders.ProductID
    INNER JOIN Semesters sr ON sr.SemesterID = r.SemesterID
    INNER JOIN Studies s ON s.StudyID = sr.StudyID
WHERE 
    Payments.Status = 0 AND 
    r.EndDate < GETDATE();

GO
/****** Object:  View [dbo].[WebinarDebtors]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WebinarDebtors] AS
SELECT Orders.UserID, u.FirstName, u.LastName, w.WebinarName, wm.Date
FROM Orders
INNER JOIN Payments on Payments.OrderID=Orders.OrderID
INNER JOIN Users as u on u.UserID = Orders.UserID
INNER JOIN Webinars w on w.ProductID = Orders.ProductID
INNER JOIN WebinarMeetings wm on wm.WebinarID=w.WebinarID
WHERE Payments.Status = 0 AND wm.Date < getDate()
GROUP BY Orders.UserID, u.FirstName, u.LastName,w.WebinarName, wm.Date;
GO
/****** Object:  View [dbo].[CourseDebtors]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CourseDebtors] AS
SELECT Orders.UserID, u.FirstName, u.LastName, c.CourseName, c.StartDate
FROM Orders
INNER JOIN Payments on Payments.OrderID=Orders.OrderID
INNER JOIN Users as u on u.UserID = Orders.UserID
INNER JOIN Courses c on c.ProductID = Orders.ProductID
WHERE Payments.Status = 0 AND c.EndDate < getDate()
GROUP BY Orders.UserID, u.FirstName, u.LastName, c.CourseName, c.StartDate;
GO
/****** Object:  Table [dbo].[WebinarParticipants]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WebinarParticipants](
	[WebinarParticipantID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[WebinarMeetingID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[WebinarParticipantID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[FutureWebinarParticipants]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FutureWebinarParticipants] AS
SELECT  count(wb.WebinarParticipantID) as NumberOfPeople, Webinars.WebinarName, 'online' as mode, w.Date as WebinarDate
FROM WebinarParticipants wb
INNER JOIN WebinarMeetings as w on w.WebinarMeetingID = wb.WebinarMeetingID
INNER JOIN Webinars on Webinars.WebinarID =w.WebinarID
WHERE w.Date > getDate()
GROUP BY Webinars.WebinarName, w.Date


GO
/****** Object:  Table [dbo].[Lecturers]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lecturers](
	[LecturerID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[LecturerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Modules]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Modules](
	[ModuleID] [int] IDENTITY(1,1) NOT NULL,
	[CourseID] [int] NULL,
	[LecturerID] [int] NULL,
	[ModuleName] [nvarchar](50) NOT NULL,
	[ModuleType] [nvarchar](20) NOT NULL,
	[Date] [datetime] NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ModuleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ModulesLecturers]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ModulesLecturers] AS
SELECT l.LecturerID, u.FirstName, u.LastName, u.Email, c.CourseName, m.ModuleName, m.Date
from Modules m
inner join Courses as c on c.CourseID=m.CourseID
inner join Lecturers as l on l.LecturerID=m.LecturerID
inner join Users as u on u.UserID=l.UserID
group by l.LecturerID, u.FirstName, u.LastName, u.Email, c.CourseName, m.ModuleName, m.Date
GO
/****** Object:  View [dbo].[WebinarLecturers]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WebinarLecturers] AS
SELECT l.LecturerID, u.FirstName, u.LastName, u.Email, w.WebinarName, wm.Date
from WebinarMeetings wm
inner join Webinars as w on w.WebinarID=wm.WebinarID
inner join Lecturers as l on l.LecturerID=wm.LecturerID
inner join Users as u on u.UserID=l.UserID
group by l.LecturerID, u.FirstName, u.LastName, u.Email, w.WebinarName, wm.Date
GO
/****** Object:  Table [dbo].[Subjects]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Subjects](
	[SubjectID] [int] IDENTITY(1,1) NOT NULL,
	[SemesterID] [int] NULL,
	[SubjectName] [nvarchar](30) NOT NULL,
	[Description] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[SubjectID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StudyMeetings]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudyMeetings](
	[StudyMeetingID] [int] IDENTITY(1,1) NOT NULL,
	[SubjectID] [int] NULL,
	[LecturerID] [int] NULL,
	[MeetingType] [nvarchar](20) NOT NULL,
	[Date] [datetime] NOT NULL,
	[StartTime] [time](7) NOT NULL,
	[EndTime] [time](7) NOT NULL,
	[MaxStudents] [int] NOT NULL,
	[MaxOtherParticipants] [int] NOT NULL,
	[ReunionID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[StudyMeetingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[StudyMeetingLecturers]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--lista prowadzacych, jakie eventy prowadza
CREATE VIEW [dbo].[StudyMeetingLecturers] AS
SELECT l.LecturerID, u.FirstName, u.LastName, u.Email, s.StudyName, sb.SubjectName, sm.Date as MeetingDate
from StudyMeetings sm
inner join Subjects sb on sb.SubjectID=sm.SubjectID
inner join Semesters as sem on sem.SemesterID=sb.SemesterID
inner join Studies as s on s.StudyID=sem.StudyID
inner join Lecturers as l on l.LecturerID=sm.LecturerID
inner join Users as u on u.UserID=l.UserID
group by l.LecturerID, u.FirstName, u.LastName, u.Email, s.StudyName, sb.SubjectName, sm.Date



GO
/****** Object:  View [dbo].[CoursesAndModules]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--lista prowadzacych, jakie eventy prowad
CREATE VIEW [dbo].[CoursesAndModules] AS
SELECT c.CourseName, c.StartDate AS CourseStartDate, m.ModuleName, m.Date AS ModuleDate, m.ModuleType, m.StartTime, m.EndTime
FROM Courses c
INNER JOIN Modules AS m ON m.CourseID=c.CourseID
GROUP BY c.CourseName, c.StartDate, m.ModuleName, m.Date, m.ModuleType, m.StartTime, m.EndTime



GO
/****** Object:  Table [dbo].[UsersAccounts]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsersAccounts](
	[Login] [nvarchar](100) NOT NULL,
	[Password] [nvarchar](30) NOT NULL,
	[UserID] [int] NULL,
	[AccountID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_UsersAccounts] PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UC_Login] UNIQUE NONCLUSTERED 
(
	[Login] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[RoleID] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](30) NOT NULL,
	[Description] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[LoginPassword]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--lista prowadzacych, jakie eventy prowad
CREATE VIEW [dbo].[LoginPassword] AS
SELECT u.UserID, u.FirstName, u.LastName, r.RoleName, u.Email, ua.Login, ua.Password
FROM UsersAccounts ua
INNER JOIN Users AS u ON u.UserID=ua.UserID
INNER JOIN UserRole AS ur ON ur.UserID=ua.UserID
INNER JOIN Roles AS r ON r.RoleID=ur.RoleID


GO
/****** Object:  View [dbo].[ReunionsIncome]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ReunionsIncome] AS
SELECT 
Orders.ProductID,
    SUM(Orders.Price) AS Income,   
    s.StudyName AS StudyName
FROM Orders
INNER JOIN Reunions AS r ON r.ProductID = Orders.ProductID
INNER JOIN Semesters AS ss ON ss.SemesterID = r.SemesterID
INNER JOIN Studies AS s ON s.StudyID = ss.StudyID
INNER JOIN Payments ON Payments.OrderID = Orders.OrderID
INNER JOIN Products ON Products.ProductID = Orders.ProductID
WHERE Payments.Status = 1 AND Payments.IsDeffered = 0
GROUP BY Orders.ProductID, s.StudyName;


GO
/****** Object:  View [dbo].[WebinarsIncome]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WebinarsIncome] AS
SELECT 
    SUM(Orders.Price) AS Income, 
    Orders.ProductID,
    w.WebinarName AS WebinarName
FROM Orders
INNER JOIN Webinars AS w ON w.ProductID = Orders.ProductID
INNER JOIN Payments ON Payments.OrderID = Orders.OrderID
INNER JOIN Products ON Products.ProductID = Orders.ProductID
WHERE Payments.Status = 1 AND Payments.IsDeffered = 0
GROUP BY Orders.ProductID, w.WebinarName
GO
/****** Object:  View [dbo].[CoursesIncome]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CoursesIncome] AS
SELECT 
    SUM(Orders.Price) AS Income, 
    Orders.ProductID,  
    c.CourseName AS CourseName
FROM Orders
INNER JOIN Courses AS c ON c.ProductID = Orders.ProductID
INNER JOIN Payments ON Payments.OrderID = Orders.OrderID
INNER JOIN Products ON Products.ProductID = Orders.ProductID
WHERE Payments.Status = 1 AND Payments.IsDeffered = 0
GROUP BY Orders.ProductID, Products.ProductType, c.CourseName
GO
/****** Object:  View [dbo].[IncomeSummary]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IncomeSummary] AS
SELECT 
    SUM(Orders.Price) AS Income, 
    Orders.ProductID, 
    Products.ProductType, 
    w.WebinarName AS EventName
FROM Orders
INNER JOIN Webinars AS w ON w.ProductID = Orders.ProductID
INNER JOIN Payments ON Payments.OrderID = Orders.OrderID
INNER JOIN Products ON Products.ProductID = Orders.ProductID
WHERE Payments.Status = 1 AND Payments.IsDeffered = 0
GROUP BY Orders.ProductID, Products.ProductType, w.WebinarName

UNION

SELECT 
    SUM(Orders.Price) AS Income, 
    Orders.ProductID, 
    Products.ProductType, 
    c.CourseName AS EventName
FROM Orders
INNER JOIN Courses AS c ON c.ProductID = Orders.ProductID
INNER JOIN Payments ON Payments.OrderID = Orders.OrderID
INNER JOIN Products ON Products.ProductID = Orders.ProductID
WHERE Payments.Status = 1 AND Payments.IsDeffered = 0
GROUP BY Orders.ProductID, Products.ProductType, c.CourseName

UNION

SELECT 
    SUM(Orders.Price) AS Income, 
    Orders.ProductID, 
    Products.ProductType, 
    s.StudyName AS EventName
FROM Orders
INNER JOIN Reunions AS r ON r.ProductID = Orders.ProductID
INNER JOIN Semesters AS ss ON ss.SemesterID = r.SemesterID
INNER JOIN Studies AS s ON s.StudyID = ss.StudyID
INNER JOIN Payments ON Payments.OrderID = Orders.OrderID
INNER JOIN Products ON Products.ProductID = Orders.ProductID
WHERE Payments.Status = 1 AND Payments.IsDeffered = 0
GROUP BY Orders.ProductID, Products.ProductType, s.StudyName;



GO
/****** Object:  View [dbo].[StudySubjects]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StudySubjects] AS
SELECT
    s.StudyName,
    s.SemesterCount,
    STRING_AGG(sb.SubjectName, ', ') AS Subjects
FROM Studies s
INNER JOIN Semesters ss ON ss.StudyID = s.StudyID
INNER JOIN Subjects sb ON sb.SemesterID = ss.SemesterID
GROUP BY s.StudyName, s.SemesterCount;
GO
/****** Object:  Table [dbo].[CourseParticipants]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourseParticipants](
	[CourseParticipantID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[CourseID] [int] NULL,
	[PostalCode] [nvarchar](6) NOT NULL,
	[CityID] [int] NULL,
	[Address] [nvarchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CourseParticipantID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[CourseParticipantsPayments]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CourseParticipantsPayments] AS
SELECT
    u.UserID,
    u.FirstName,
	u.LastName,
    c.CourseID,
    c.CourseName,
	c.StartDate,
	p.Status,
	pr.ProductPrice AS CoursePrice
FROM CourseParticipants cp
INNER JOIN Courses c ON c.CourseID = cp.CourseID
INNER JOIN Users u ON cp.UserID = u.UserID
INNER JOIN Orders o ON o.ProductID=c.ProductID
INNER JOIN Payments p ON p.OrderID=o.OrderID
INNER JOIN Products pr ON pr.ProductID=c.ProductID

GO
/****** Object:  View [dbo].[WebinarParticipantsPayments]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WebinarParticipantsPayments] AS
SELECT
    u.UserID,
    u.FirstName,
	u.LastName,
    w.WebinarID,
    w.WebinarName,
	wm.Date,
	p.Status,
	pr.ProductPrice AS WebinarPrice
FROM WebinarParticipants wp
INNER JOIN WebinarMeetings wm ON wm.WebinarMeetingID=wp.WebinarMeetingID
INNER JOIN Webinars w ON w.WebinarID = wm.WebinarID
LEFT JOIN Users u ON wp.UserID = u.UserID
INNER JOIN Orders o ON o.ProductID=w.ProductID
INNER JOIN Payments p ON p.OrderID=o.OrderID
INNER JOIN Products pr ON pr.ProductID=w.ProductID

GO
/****** Object:  Table [dbo].[Students]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Students](
	[StudentID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[StudyID] [int] NULL,
	[PostalCode] [nvarchar](6) NOT NULL,
	[CityID] [int] NULL,
	[Address] [nvarchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[StudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[StudentStudy]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StudentStudy] AS
SELECT st.StudentID, u.FirstName + ' ' + u.LastName AS StudentName, s.StudyName
FROM Students st
inner join Studies AS s ON s.StudyID=st.StudyID
inner join Users AS u ON u.UserID=st.UserID
GO
/****** Object:  Table [dbo].[Internships]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Internships](
	[InternshipID] [int] IDENTITY(1,1) NOT NULL,
	[StudentID] [int] NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[IsCompleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[InternshipID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[StudentsInternships]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StudentsInternships] AS
SELECT st.StudentID, u.FirstName + ' ' + u.LastName AS StudentName, s.StudyName, i.StartDate AS StartOfInternship, i.EndDate AS EndOfInternship, i.IsCompleted
FROM Students st
INNER JOIN Internships AS i ON i.StudentID=st.StudentID
inner join Studies AS s ON s.StudyID=st.StudyID
inner join Users AS u ON u.UserID=st.UserID
GO
/****** Object:  Table [dbo].[ExamResults]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExamResults](
	[ResultID] [int] IDENTITY(1,1) NOT NULL,
	[ExamID] [int] NULL,
	[StudentID] [int] NULL,
	[HasPassed] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ResultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ModuleAttendances]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModuleAttendances](
	[HasPassed] [bit] NOT NULL,
	[ModuleAttendanceID] [int] IDENTITY(1,1) NOT NULL,
	[ModuleID] [int] NULL,
	[CourseParticipantID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ModuleAttendanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Countries]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Countries](
	[CountryID] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [nvarchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Voivodeships]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Voivodeships](
	[VoivodeshipID] [int] IDENTITY(1,1) NOT NULL,
	[CountryID] [int] NULL,
	[VoivodeshipName] [nvarchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VoivodeshipID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cities]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cities](
	[CityID] [int] IDENTITY(1,1) NOT NULL,
	[VoivodeshipID] [int] NULL,
	[CityName] [nvarchar](60) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[CertificatesToSend]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CertificatesToSend] AS
SELECT 
    st.StudentID AS ParticipantID, 
    u.FirstName + ' ' + u.LastName AS ParticipantName,
    st.Address + ', ' + c.CityName + ',' + co.CountryName AS Address,
    s.StudyName AS CourseOrStudyName,
    'Student' AS ParticipantType
FROM Students st
INNER JOIN ExamResults er ON er.StudentID = st.StudentID
INNER JOIN Studies s ON s.StudyID = st.StudyID
INNER JOIN Users u ON u.UserID = st.UserID
INNER JOIN Cities c ON c.CityID = st.CityID
INNER JOIN Voivodeships v ON v.VoivodeshipID = c.VoivodeshipID
INNER JOIN Countries co ON co.CountryID = v.CountryID
WHERE er.HasPassed = 1

UNION ALL

SELECT 
    cp.CourseParticipantID AS ParticipantID,
    u.FirstName + ' ' + u.LastName AS ParticipantName,
    MAX(cp.Address + ', ' + ct.CityName + ',' + co.CountryName) AS Address,
    c.CourseName AS CourseOrStudyName,
    'CourseParticipant' AS ParticipantType
FROM CourseParticipants cp
INNER JOIN Users u ON u.UserID = cp.UserID
INNER JOIN Courses c ON c.CourseID = cp.CourseID
INNER JOIN Modules m ON m.CourseID = c.CourseID
INNER JOIN ModuleAttendances ma ON ma.ModuleID = m.ModuleID AND ma.CourseParticipantID = cp.CourseParticipantID
INNER JOIN Cities ct ON ct.CityID = cp.CityID
INNER JOIN Voivodeships v ON v.VoivodeshipID = ct.VoivodeshipID
INNER JOIN Countries co ON co.CountryID = v.CountryID
GROUP BY 
    cp.CourseParticipantID,
    u.FirstName,
    u.LastName,
    c.CourseName;


GO
/****** Object:  View [dbo].[CoursePassingStatus]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CoursePassingStatus] AS
SELECT 
    cp.CourseParticipantID,
    u.FirstName + ' ' + u.LastName AS ParticipantName,
    c.CourseName,
    COUNT(DISTINCT m.ModuleID) AS TotalModules,
    SUM(CASE WHEN ma.HasPassed = 1 THEN 1 ELSE 0 END) AS PassedModules,
    CASE WHEN COUNT(DISTINCT m.ModuleID) > 0 AND
              SUM(CASE WHEN ma.HasPassed = 1 THEN 1 ELSE 0 END) / COUNT(DISTINCT m.ModuleID) >= 0.8
         THEN 'Passed'
         ELSE 'Not Passed'
    END AS CourseStatus
FROM CourseParticipants cp
INNER JOIN Users u ON u.UserID = cp.UserID
INNER JOIN Courses c ON c.CourseID = cp.CourseID
INNER JOIN Modules m ON m.CourseID = c.CourseID
LEFT JOIN ModuleAttendances ma ON ma.ModuleID = m.ModuleID AND ma.CourseParticipantID = cp.CourseParticipantID
GROUP BY 
    cp.CourseParticipantID,
    u.FirstName,
    u.LastName,
    c.CourseName



	
GO
/****** Object:  View [dbo].[DefferedPayments]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DefferedPayments] AS
SELECT 
    u.FirstName + ' ' + u.LastName AS Name, 
    o.Price,
    DATEADD(DAY, 7, p.PayDate) AS UpdatedPayDate
FROM Orders o
INNER JOIN Users u ON u.UserID = o.UserID
INNER JOIN Payments p ON p.OrderID = o.OrderID
WHERE p.IsDeffered = 1;




	
GO
/****** Object:  View [dbo].[ModuleAttendanceList]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ModuleAttendanceList] AS
SELECT 
    ma.CourseParticipantID, 
    u.FirstName, 
    u.LastName, 
    m.ModuleName, 
    m.Date,
	ma.HasPassed AS WasPresent
FROM 
    ModuleAttendances ma
    INNER JOIN CourseParticipants AS cp ON cp.CourseParticipantID=ma.CourseParticipantID
    INNER JOIN Users AS u ON u.UserID = cp.UserID
    INNER JOIN Modules m ON m.ModuleID = ma.ModuleID
    
WHERE  
    m.Date < GETDATE()





	
GO
/****** Object:  View [dbo].[FutureParticipants]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FutureParticipants] AS
SELECT  count(wb.WebinarParticipantID) as NumberOfPeople, Webinars.WebinarName as EventName, 'online' as mode, p.ProductType,w.Date
FROM WebinarParticipants wb

INNER JOIN WebinarMeetings as w on w.WebinarMeetingID = wb.WebinarMeetingID
INNER JOIN Webinars on Webinars.WebinarID =w.WebinarID
INNER JOIN Products as p on p.ProductID=Webinars.ProductID
WHERE w.Date > getDate()
GROUP BY Webinars.WebinarName, p.ProductType, w.Date

UNION

SELECT  count(cp.CourseParticipantID) as NumberOfPeople, c.CourseName as EventName, m.ModuleType, 'course module' as ProductType, m.Date
FROM CourseParticipants cp
INNER JOIN Courses as c on c.CourseID = cp.CourseID
INNER JOIN Products as p on p.ProductID=c.ProductID
INNER JOIN Modules as m on m.CourseID=c.CourseID
WHERE c.StartDate > getDate()
GROUP BY c.CourseName, m.ModuleType, m.Date

UNION

SELECT  count(st.StudentID) as NumberOfPeople, s.StudyName as EventName, sm.MeetingType, p.ProductType, sm.Date
FROM Students st
INNER JOIN Studies as s on s.StudyID=st.StudyID
INNER JOIN Semesters as sr on sr.SemesterID = s.StudyID
INNER JOIN Reunions as r on r.SemesterID = sr.SemesterID
INNER JOIN Subjects as sb on sb.SemesterID=sr.SemesterID
INNER JOIN StudyMeetings as sm on sm.SubjectID=sb.SubjectID
INNER JOIN Products as p on p.ProductID=r.ProductID
WHERE r.StartDate > getDate()
GROUP BY s.StudyName, sm.MeetingType, p.ProductType, sm.Date
GO
/****** Object:  Table [dbo].[StudyMeetingAttendances]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StudyMeetingAttendances](
	[StudyMeetingAttendanceID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[HasPassed] [bit] NOT NULL,
	[StudyMeetingID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[StudyMeetingAttendanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[StudyMeetingAttendanceList]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StudyMeetingAttendanceList] AS
SELECT 
    CASE 
        WHEN s.StudentID IS NOT NULL AND u.UserID IS NOT NULL THEN 'Student' 
        WHEN u.UserID IS NOT NULL THEN 'OtherParticipant' 
    END AS ParticipantType,
    COALESCE(s.StudentID, u.UserID) AS ParticipantID,
    u.FirstName, 
    u.LastName, 
    sub.SubjectName AS EventName, 
    sm.Date AS EventDate,
    sma.HasPassed AS WasPresent
FROM
    StudyMeetingAttendances sma
LEFT JOIN Students s ON s.StudentID = sma.UserID
LEFT JOIN Users AS u ON u.UserID = sma.UserID
INNER JOIN StudyMeetings sm ON sm.StudyMeetingID = sma.StudyMeetingID
INNER JOIN Subjects sub ON sub.SubjectID = sm.SubjectID
WHERE 
    sm.Date < GETDATE();


GO
/****** Object:  Table [dbo].[WebinarAttendances]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WebinarAttendances](
	[WebinarAttendanceID] [int] IDENTITY(1,1) NOT NULL,
	[HasPassed] [bit] NOT NULL,
	[WebinarParticipantID] [int] NULL,
	[WebinarMeetingID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[WebinarAttendanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[WebinarAttendanceList]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[WebinarAttendanceList] AS
SELECT 
    wa.WebinarParticipantID, 
    u.FirstName, 
    u.LastName, 
    w.WebinarName, 
    wm.Date,
	wa.HasPassed AS WasPresent
FROM 
    WebinarAttendances wa

    INNER JOIN WebinarParticipants AS wp ON wp.WebinarParticipantID=wa.WebinarParticipantID
    INNER JOIN Users AS u ON u.UserID = wp.UserID
	INNER JOIN WebinarMeetings AS wm ON wm.WebinarMeetingID=wa.WebinarMeetingID
    INNER JOIN Webinars AS w ON w.WebinarID=wm.WebinarID
    
WHERE  
    wm.Date < GETDATE()



GO
/****** Object:  View [dbo].[FutureStudyMeetingParticipants]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FutureStudyMeetingParticipants] AS
SELECT 
    COUNT(DISTINCT COALESCE(s.StudentID, u.UserID)) AS NumberOfPeople,
    st.StudyName as Studies,
    sub.SubjectName,
    sm.Date
FROM
    StudyMeetingAttendances sma
LEFT JOIN Students s ON s.StudentID = sma.UserID
LEFT JOIN Users AS u ON u.UserID = sma.UserID
INNER JOIN StudyMeetings sm ON sm.StudyMeetingID = sma.StudyMeetingID
INNER JOIN Subjects sub ON sub.SubjectID = sm.SubjectID
INNER JOIN Semesters AS sem ON sem.SemesterID = sub.SemesterID
INNER JOIN Studies AS st ON st.StudyID = sem.StudyID
WHERE 
    sm.Date > GETDATE()
GROUP BY
    st.StudyName,
    sub.SubjectName,
    sm.Date;

GO
/****** Object:  View [dbo].[AttendanceRate]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AttendanceRate] AS
SELECT
    'StudyMeeting' AS EventType,
    sm.StudyMeetingID AS EventID,
    sub.SubjectName AS EventName,
    sm.MeetingType AS MeetingType,
    COUNT(DISTINCT CASE WHEN sma.HasPassed = 1 THEN sma.UserID END) AS PresentParticipants,
    COUNT(DISTINCT CASE WHEN sma.HasPassed = 0 THEN sma.UserID END) AS AbsentParticipants,
    CASE
        WHEN COUNT(DISTINCT CASE WHEN sma.HasPassed = 1 THEN sma.UserID END) + COUNT(DISTINCT CASE WHEN sma.HasPassed = 0 THEN sma.UserID END) > 0
        THEN (COUNT(DISTINCT CASE WHEN sma.HasPassed = 1 THEN sma.UserID END) * 100) / (COUNT(DISTINCT CASE WHEN sma.HasPassed = 1 THEN sma.UserID END) + COUNT(DISTINCT CASE WHEN sma.HasPassed = 0 THEN sma.UserID END))
        ELSE NULL
    END AS AttendanceRate
FROM
    StudyMeetings sm
INNER JOIN
    Subjects sub ON sub.SubjectID = sm.SubjectID
LEFT JOIN
    StudyMeetingAttendances sma ON sma.StudyMeetingID = sm.StudyMeetingID
WHERE
    sm.Date < GETDATE()
GROUP BY
    sm.StudyMeetingID, sub.SubjectName, sm.MeetingType

UNION

SELECT
    'WebinarMeeting' AS EventType,
    wm.WebinarMeetingID AS EventID,
    w.WebinarName AS EventName,
    'online' AS MeetingType,
    COUNT(DISTINCT CASE WHEN wa.HasPassed = 1 THEN wa.WebinarParticipantID END) AS PresentParticipants,
    COUNT(DISTINCT CASE WHEN wa.HasPassed = 0 THEN wa.WebinarParticipantID END) AS AbsentParticipants,
    CASE
        WHEN COUNT(DISTINCT CASE WHEN wa.HasPassed = 1 THEN wa.WebinarParticipantID END) + COUNT(DISTINCT CASE WHEN wa.HasPassed = 0 THEN wa.WebinarParticipantID END) > 0
        THEN (COUNT(DISTINCT CASE WHEN wa.HasPassed = 1 THEN wa.WebinarParticipantID END) * 100) / (COUNT(DISTINCT CASE WHEN wa.HasPassed = 1 THEN wa.WebinarParticipantID END) + COUNT(DISTINCT CASE WHEN wa.HasPassed = 0 THEN wa.WebinarParticipantID END))
        ELSE NULL
    END AS AttendanceRate
FROM
    WebinarMeetings wm
INNER JOIN
    Webinars w ON w.WebinarID = wm.WebinarID
LEFT JOIN
    WebinarAttendances wa ON wa.WebinarMeetingID = wm.WebinarMeetingID
WHERE
    wm.Date < GETDATE()
GROUP BY
    wm.WebinarMeetingID, w.WebinarName

UNION

SELECT
    'Module' AS EventType,
    m.ModuleID AS EventID,
    c.CourseName AS EventName,
    m.ModuleType AS MeetingType,
    COUNT(DISTINCT CASE WHEN ma.HasPassed = 1 THEN ma.CourseParticipantID END) AS PresentParticipants,
    COUNT(DISTINCT CASE WHEN ma.HasPassed = 0 THEN ma.CourseParticipantID END) AS AbsentParticipants,
    CASE
        WHEN COUNT(DISTINCT CASE WHEN ma.HasPassed = 1 THEN ma.CourseParticipantID END) + COUNT(DISTINCT CASE WHEN ma.HasPassed = 0 THEN ma.CourseParticipantID END) > 0
        THEN (COUNT(DISTINCT CASE WHEN ma.HasPassed = 1 THEN ma.CourseParticipantID END) * 100) / (COUNT(DISTINCT CASE WHEN ma.HasPassed = 1 THEN ma.CourseParticipantID END) + COUNT(DISTINCT CASE WHEN ma.HasPassed = 0 THEN ma.CourseParticipantID END))
        ELSE NULL
    END AS AttendanceRate
FROM
    Modules m
INNER JOIN
    Courses c ON c.CourseID = m.CourseID
LEFT JOIN
    ModuleAttendances ma ON ma.ModuleID = m.ModuleID
WHERE
    m.Date < GETDATE()
GROUP BY
    m.ModuleID, c.CourseName, m.ModuleType;
GO
/****** Object:  View [dbo].[OverlappingMeetings]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OverlappingMeetings] AS
WITH OverlappingMeetings AS (
    SELECT 
        'Webinar' AS MeetingType,
        DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', WM.StartTime), WM.Date) AS StartDateTime,
        DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', WM.EndTime), WM.Date) AS EndDateTime,
        WM.WebinarMeetingID AS MeetingID,
        w.WebinarName,
        NULL AS ModuleName,
        NULL AS Subject
    FROM 
        WebinarMeetings WM
	INNER JOIN Webinars w ON w.WebinarID = wm.WebinarID
    UNION ALL
    SELECT 
        'StudyMeeting' AS MeetingType,
        DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', SM.StartTime), SM.Date) AS StartDateTime,
        DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', SM.EndTime), SM.Date) AS EndDateTime,
        SM.StudyMeetingID AS MeetingID,
        NULL AS WebinarName,
       NULL AS ModuleName,
        SUB.SubjectName
    FROM 
        StudyMeetings SM
    INNER JOIN Subjects sub ON SM.SubjectID = sub.SubjectID
	
    UNION ALL
    SELECT 
        'Module' AS MeetingType,
        DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', M.StartTime), M.Date) AS StartDateTime,
        DATEADD(MINUTE, DATEDIFF(MINUTE, '00:00', M.EndTime), M.Date) AS EndDateTime,
        M.ModuleID AS MeetingID,
        NULL AS WebinarName,
        M.ModuleName,
        NULL AS Subject
    FROM 
        Modules M
)
SELECT 
    OM1.MeetingType AS MeetingType1,
    OM1.MeetingID AS MeetingID1,
    OM1.StartDateTime AS StartDateTime1,
    OM1.EndDateTime AS EndDateTime1,
    OM1.WebinarName AS WebinarName1,
    OM1.ModuleName AS ModuleName1,
    OM1.Subject AS Subject1,
    OM2.MeetingType AS MeetingType2,
    OM2.MeetingID AS MeetingID2,
    OM2.StartDateTime AS StartDateTime2,
    OM2.EndDateTime AS EndDateTime2,
    OM2.WebinarName AS WebinarName2,
    OM2.ModuleName AS ModuleName2,
    OM2.Subject AS Subject2
FROM 
    OverlappingMeetings OM1
INNER JOIN 
    OverlappingMeetings OM2 ON OM1.MeetingID < OM2.MeetingID
    AND OM1.StartDateTime < OM2.EndDateTime
    AND OM1.EndDateTime > OM2.StartDateTime;


GO
/****** Object:  View [dbo].[FutureCourseParticipants]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FutureCourseParticipants] AS
SELECT  count(cp.CourseParticipantID) as NumberOfPeople, c.CourseName, c.StartDate
FROM CourseParticipants cp
INNER JOIN Courses as c on c.CourseID = cp.CourseID
WHERE c.StartDate > getDate()
GROUP BY c.CourseName, c.StartDate
GO
/****** Object:  Table [dbo].[AsynchronicOnlineModules]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AsynchronicOnlineModules](
	[AsynchronicOnlineModuleID] [int] IDENTITY(1,1) NOT NULL,
	[ModuleID] [int] NULL,
	[RecordingLink] [nvarchar](255) NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AsynchronicOnlineModuleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AsynchronicOnlineStudyMeetings]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AsynchronicOnlineStudyMeetings](
	[AsynchronicOnlineStudyMeetingID] [int] IDENTITY(1,1) NOT NULL,
	[StudyMeetingID] [int] NULL,
	[RecordingLink] [nvarchar](255) NOT NULL,
	[ExpirationDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AsynchronicOnlineStudyMeetingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Exams]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Exams](
	[ExamID] [int] IDENTITY(1,1) NOT NULL,
	[StudyID] [int] NULL,
	[ExamDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ExamID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Languages]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Languages](
	[LanguageID] [int] IDENTITY(1,1) NOT NULL,
	[LanguageName] [nvarchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Locations]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Locations](
	[LocationID] [int] IDENTITY(1,1) NOT NULL,
	[CityID] [int] NULL,
	[Street] [nvarchar](30) NOT NULL,
	[Building] [int] NULL,
	[Classroom] [int] NOT NULL,
	[PostalCode] [nvarchar](10) NOT NULL,
	[Capacity] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ModulesInForeignLanguages]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ModulesInForeignLanguages](
	[ModulesInForeignLanguageID] [int] IDENTITY(1,1) NOT NULL,
	[LanguageID] [int] NULL,
	[TranslatorID] [int] NULL,
	[ModuleID] [int] NULL,
 CONSTRAINT [PK_ModulesInForeignLanguages] PRIMARY KEY CLUSTERED 
(
	[ModulesInForeignLanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OfflineModules]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OfflineModules](
	[OfflineModuleID] [int] IDENTITY(1,1) NOT NULL,
	[ModuleID] [int] NULL,
	[MaxParticipants] [int] NULL,
	[LocationID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[OfflineModuleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OfflineStudyMeetings]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OfflineStudyMeetings](
	[OfflineStudyMeetingID] [int] IDENTITY(1,1) NOT NULL,
	[StudyMeetingID] [int] NULL,
	[LocationID] [int] NULL,
	[MaxParticipants] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[OfflineStudyMeetingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubjectsInForeignLanguages]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubjectsInForeignLanguages](
	[SubjectID] [int] NULL,
	[LanguageID] [int] NULL,
	[TranslatorID] [int] NULL,
	[SubjectInForeignLanguagesID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_SubjectsInForeignLanguages] PRIMARY KEY CLUSTERED 
(
	[SubjectInForeignLanguagesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SynchronicOnlineModules]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SynchronicOnlineModules](
	[SynchronicOnlineModuleID] [int] IDENTITY(1,1) NOT NULL,
	[ModuleID] [int] NULL,
	[MeetingLink] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SynchronicOnlineModuleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SynchronicOnlineStudyMeetings]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SynchronicOnlineStudyMeetings](
	[SynchronicOnlineStudyMeetingID] [int] IDENTITY(1,1) NOT NULL,
	[StudyMeetingID] [int] NULL,
	[MeetingLink] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SynchronicOnlineStudyMeetingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Translators]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Translators](
	[TranslatorID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[LanguageID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[TranslatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WebinarsInForeignLanguages]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WebinarsInForeignLanguages](
	[WebinarInForeignLanguagesID] [int] IDENTITY(1,1) NOT NULL,
	[WebinarID] [int] NULL,
	[LanguageID] [int] NULL,
	[TranslatorID] [int] NULL,
 CONSTRAINT [PK_WebinarsInForeignLanguages] PRIMARY KEY CLUSTERED 
(
	[WebinarInForeignLanguagesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IDX_CourseParticipants_CityID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_CourseParticipants_CityID] ON [dbo].[CourseParticipants]
(
	[CityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_CourseParticipants_CourseID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_CourseParticipants_CourseID] ON [dbo].[CourseParticipants]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_CourseParticipants_UserID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_CourseParticipants_UserID] ON [dbo].[CourseParticipants]
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Courses_EndDate]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Courses_EndDate] ON [dbo].[Courses]
(
	[EndDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Courses_LanguageID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Courses_LanguageID] ON [dbo].[Courses]
(
	[LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Courses_StartDate]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Courses_StartDate] ON [dbo].[Courses]
(
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Modules_CourseID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Modules_CourseID] ON [dbo].[Modules]
(
	[CourseID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Modules_Date]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Modules_Date] ON [dbo].[Modules]
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Modules_LecturerID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Modules_LecturerID] ON [dbo].[Modules]
(
	[LecturerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Orders_Price]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Orders_Price] ON [dbo].[Orders]
(
	[Price] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Orders_ProductID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Orders_ProductID] ON [dbo].[Orders]
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Orders_UserID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Orders_UserID] ON [dbo].[Orders]
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Orders_UserID_ProductID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Orders_UserID_ProductID] ON [dbo].[Orders]
(
	[UserID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Payments_OrderID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Payments_OrderID] ON [dbo].[Payments]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Payments_PayDate]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Payments_PayDate] ON [dbo].[Payments]
(
	[PayDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_Payments_Status]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Payments_Status] ON [dbo].[Payments]
(
	[Status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Users_Email]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Users_Email] ON [dbo].[Users]
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_Users_FirstName_LastName]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_Users_FirstName_LastName] ON [dbo].[Users]
(
	[FirstName] ASC,
	[LastName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_WebinarMeetings_Date_WebinarID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_WebinarMeetings_Date_WebinarID] ON [dbo].[WebinarMeetings]
(
	[Date] ASC,
	[WebinarID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IDX_WebinarMeetings_LecturerID]    Script Date: 23.02.2024 15:12:23 ******/
CREATE NONCLUSTERED INDEX [IDX_WebinarMeetings_LecturerID] ON [dbo].[WebinarMeetings]
(
	[LecturerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ExamResults] ADD  DEFAULT ((0)) FOR [HasPassed]
GO
ALTER TABLE [dbo].[Internships] ADD  DEFAULT ((0)) FOR [IsCompleted]
GO
ALTER TABLE [dbo].[ModuleAttendances] ADD  DEFAULT ((0)) FOR [HasPassed]
GO
ALTER TABLE [dbo].[Orders] ADD  CONSTRAINT [DF_Orders_Quantity]  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[Payments] ADD  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[Payments] ADD  CONSTRAINT [DF_Payments_PayDate]  DEFAULT (getdate()) FOR [PayDate]
GO
ALTER TABLE [dbo].[Payments] ADD  DEFAULT ((0)) FOR [IsDeffered]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0)) FOR [ProductPrice]
GO
ALTER TABLE [dbo].[StudyMeetingAttendances] ADD  DEFAULT ((0)) FOR [HasPassed]
GO
ALTER TABLE [dbo].[AsynchronicOnlineModules]  WITH CHECK ADD FOREIGN KEY([ModuleID])
REFERENCES [dbo].[Modules] ([ModuleID])
GO
ALTER TABLE [dbo].[AsynchronicOnlineStudyMeetings]  WITH CHECK ADD FOREIGN KEY([StudyMeetingID])
REFERENCES [dbo].[StudyMeetings] ([StudyMeetingID])
GO
ALTER TABLE [dbo].[Cities]  WITH CHECK ADD FOREIGN KEY([VoivodeshipID])
REFERENCES [dbo].[Voivodeships] ([VoivodeshipID])
GO
ALTER TABLE [dbo].[CourseParticipants]  WITH CHECK ADD FOREIGN KEY([CityID])
REFERENCES [dbo].[Cities] ([CityID])
GO
ALTER TABLE [dbo].[CourseParticipants]  WITH CHECK ADD FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([CourseID])
GO
ALTER TABLE [dbo].[CourseParticipants]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[ExamResults]  WITH CHECK ADD FOREIGN KEY([ExamID])
REFERENCES [dbo].[Exams] ([ExamID])
GO
ALTER TABLE [dbo].[ExamResults]  WITH CHECK ADD FOREIGN KEY([StudentID])
REFERENCES [dbo].[Students] ([StudentID])
GO
ALTER TABLE [dbo].[Exams]  WITH CHECK ADD FOREIGN KEY([StudyID])
REFERENCES [dbo].[Studies] ([StudyID])
GO
ALTER TABLE [dbo].[Internships]  WITH CHECK ADD FOREIGN KEY([StudentID])
REFERENCES [dbo].[Students] ([StudentID])
GO
ALTER TABLE [dbo].[Lecturers]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Locations]  WITH CHECK ADD FOREIGN KEY([CityID])
REFERENCES [dbo].[Cities] ([CityID])
GO
ALTER TABLE [dbo].[ModuleAttendances]  WITH CHECK ADD  CONSTRAINT [FK_CourseParticipantID] FOREIGN KEY([CourseParticipantID])
REFERENCES [dbo].[CourseParticipants] ([CourseParticipantID])
GO
ALTER TABLE [dbo].[ModuleAttendances] CHECK CONSTRAINT [FK_CourseParticipantID]
GO
ALTER TABLE [dbo].[ModuleAttendances]  WITH CHECK ADD  CONSTRAINT [FK_ModuleID] FOREIGN KEY([ModuleID])
REFERENCES [dbo].[Modules] ([ModuleID])
GO
ALTER TABLE [dbo].[ModuleAttendances] CHECK CONSTRAINT [FK_ModuleID]
GO
ALTER TABLE [dbo].[Modules]  WITH CHECK ADD FOREIGN KEY([CourseID])
REFERENCES [dbo].[Courses] ([CourseID])
GO
ALTER TABLE [dbo].[Modules]  WITH CHECK ADD FOREIGN KEY([LecturerID])
REFERENCES [dbo].[Lecturers] ([LecturerID])
GO
ALTER TABLE [dbo].[ModulesInForeignLanguages]  WITH CHECK ADD FOREIGN KEY([LanguageID])
REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[ModulesInForeignLanguages]  WITH CHECK ADD FOREIGN KEY([TranslatorID])
REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[ModulesInForeignLanguages]  WITH CHECK ADD  CONSTRAINT [FK_ModulesInForeignLanguages_Modules] FOREIGN KEY([ModuleID])
REFERENCES [dbo].[Modules] ([ModuleID])
GO
ALTER TABLE [dbo].[ModulesInForeignLanguages] CHECK CONSTRAINT [FK_ModulesInForeignLanguages_Modules]
GO
ALTER TABLE [dbo].[OfflineModules]  WITH CHECK ADD FOREIGN KEY([LocationID])
REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[OfflineModules]  WITH CHECK ADD FOREIGN KEY([ModuleID])
REFERENCES [dbo].[Modules] ([ModuleID])
GO
ALTER TABLE [dbo].[OfflineStudyMeetings]  WITH CHECK ADD FOREIGN KEY([LocationID])
REFERENCES [dbo].[Locations] ([LocationID])
GO
ALTER TABLE [dbo].[OfflineStudyMeetings]  WITH CHECK ADD FOREIGN KEY([StudyMeetingID])
REFERENCES [dbo].[StudyMeetings] ([StudyMeetingID])
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[Reunions]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Reunions]  WITH CHECK ADD FOREIGN KEY([SemesterID])
REFERENCES [dbo].[Semesters] ([SemesterID])
GO
ALTER TABLE [dbo].[Semesters]  WITH CHECK ADD FOREIGN KEY([StudyID])
REFERENCES [dbo].[Studies] ([StudyID])
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD FOREIGN KEY([CityID])
REFERENCES [dbo].[Cities] ([CityID])
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD FOREIGN KEY([StudyID])
REFERENCES [dbo].[Studies] ([StudyID])
GO
ALTER TABLE [dbo].[Students]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[StudyMeetingAttendances]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[StudyMeetingAttendances]  WITH CHECK ADD  CONSTRAINT [FK_Study_MeetingID] FOREIGN KEY([StudyMeetingID])
REFERENCES [dbo].[StudyMeetings] ([StudyMeetingID])
GO
ALTER TABLE [dbo].[StudyMeetingAttendances] CHECK CONSTRAINT [FK_Study_MeetingID]
GO
ALTER TABLE [dbo].[StudyMeetings]  WITH CHECK ADD FOREIGN KEY([LecturerID])
REFERENCES [dbo].[Lecturers] ([LecturerID])
GO
ALTER TABLE [dbo].[StudyMeetings]  WITH CHECK ADD FOREIGN KEY([SubjectID])
REFERENCES [dbo].[Subjects] ([SubjectID])
GO
ALTER TABLE [dbo].[Subjects]  WITH CHECK ADD FOREIGN KEY([SemesterID])
REFERENCES [dbo].[Semesters] ([SemesterID])
GO
ALTER TABLE [dbo].[SubjectsInForeignLanguages]  WITH CHECK ADD FOREIGN KEY([LanguageID])
REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[SubjectsInForeignLanguages]  WITH CHECK ADD FOREIGN KEY([TranslatorID])
REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[SubjectsInForeignLanguages]  WITH CHECK ADD  CONSTRAINT [FK_SubjectsInForeignLanguages_Subjects] FOREIGN KEY([SubjectID])
REFERENCES [dbo].[Subjects] ([SubjectID])
GO
ALTER TABLE [dbo].[SubjectsInForeignLanguages] CHECK CONSTRAINT [FK_SubjectsInForeignLanguages_Subjects]
GO
ALTER TABLE [dbo].[SynchronicOnlineModules]  WITH CHECK ADD FOREIGN KEY([ModuleID])
REFERENCES [dbo].[Modules] ([ModuleID])
GO
ALTER TABLE [dbo].[SynchronicOnlineStudyMeetings]  WITH CHECK ADD FOREIGN KEY([StudyMeetingID])
REFERENCES [dbo].[StudyMeetings] ([StudyMeetingID])
GO
ALTER TABLE [dbo].[Translators]  WITH CHECK ADD FOREIGN KEY([LanguageID])
REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[Translators]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Roles] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Roles] ([RoleID])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Roles]
GO
ALTER TABLE [dbo].[UsersAccounts]  WITH CHECK ADD  CONSTRAINT [FK_UsersAccounts_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[UsersAccounts] CHECK CONSTRAINT [FK_UsersAccounts_Users]
GO
ALTER TABLE [dbo].[Voivodeships]  WITH CHECK ADD FOREIGN KEY([CountryID])
REFERENCES [dbo].[Countries] ([CountryID])
GO
ALTER TABLE [dbo].[WebinarAttendances]  WITH CHECK ADD  CONSTRAINT [FK_WebinarMeetingID] FOREIGN KEY([WebinarMeetingID])
REFERENCES [dbo].[WebinarMeetings] ([WebinarMeetingID])
GO
ALTER TABLE [dbo].[WebinarAttendances] CHECK CONSTRAINT [FK_WebinarMeetingID]
GO
ALTER TABLE [dbo].[WebinarAttendances]  WITH CHECK ADD  CONSTRAINT [FK_WebinarParticipantID] FOREIGN KEY([WebinarParticipantID])
REFERENCES [dbo].[WebinarParticipants] ([WebinarParticipantID])
GO
ALTER TABLE [dbo].[WebinarAttendances] CHECK CONSTRAINT [FK_WebinarParticipantID]
GO
ALTER TABLE [dbo].[WebinarMeetings]  WITH CHECK ADD FOREIGN KEY([LecturerID])
REFERENCES [dbo].[Lecturers] ([LecturerID])
GO
ALTER TABLE [dbo].[WebinarMeetings]  WITH CHECK ADD FOREIGN KEY([WebinarID])
REFERENCES [dbo].[Webinars] ([WebinarID])
GO
ALTER TABLE [dbo].[WebinarParticipants]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[WebinarParticipants]  WITH CHECK ADD FOREIGN KEY([WebinarMeetingID])
REFERENCES [dbo].[WebinarMeetings] ([WebinarMeetingID])
GO
ALTER TABLE [dbo].[Webinars]  WITH CHECK ADD  CONSTRAINT [FK_Webinars_Languages] FOREIGN KEY([LanguageID])
REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[Webinars] CHECK CONSTRAINT [FK_Webinars_Languages]
GO
ALTER TABLE [dbo].[Webinars]  WITH CHECK ADD  CONSTRAINT [FK_Webinars_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Webinars] CHECK CONSTRAINT [FK_Webinars_Products]
GO
ALTER TABLE [dbo].[WebinarsInForeignLanguages]  WITH CHECK ADD FOREIGN KEY([LanguageID])
REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[WebinarsInForeignLanguages]  WITH CHECK ADD FOREIGN KEY([TranslatorID])
REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[WebinarsInForeignLanguages]  WITH CHECK ADD  CONSTRAINT [FK_WebinarsInForeignLanguages_Webinars] FOREIGN KEY([WebinarID])
REFERENCES [dbo].[Webinars] ([WebinarID])
GO
ALTER TABLE [dbo].[WebinarsInForeignLanguages] CHECK CONSTRAINT [FK_WebinarsInForeignLanguages_Webinars]
GO
ALTER TABLE [dbo].[AsynchronicOnlineModules]  WITH CHECK ADD  CONSTRAINT [CHK_RecordingLink_Format] CHECK  (([RecordingLink] like 'https://%.com'))
GO
ALTER TABLE [dbo].[AsynchronicOnlineModules] CHECK CONSTRAINT [CHK_RecordingLink_Format]
GO
ALTER TABLE [dbo].[AsynchronicOnlineStudyMeetings]  WITH CHECK ADD  CONSTRAINT [CHK_RecordingLink_Format_StudyMeetings] CHECK  (([RecordingLink] like 'https://%.com'))
GO
ALTER TABLE [dbo].[AsynchronicOnlineStudyMeetings] CHECK CONSTRAINT [CHK_RecordingLink_Format_StudyMeetings]
GO
ALTER TABLE [dbo].[Courses]  WITH CHECK ADD  CONSTRAINT [CHK_EndDate_Greater] CHECK  (([EndDate]>[StartDate]))
GO
ALTER TABLE [dbo].[Courses] CHECK CONSTRAINT [CHK_EndDate_Greater]
GO
ALTER TABLE [dbo].[Modules]  WITH CHECK ADD  CONSTRAINT [CHK_Modules_ModuleType] CHECK  (([ModuleType]='hybrid' OR [ModuleType]='stationary' OR [ModuleType]='synchronic online' OR [ModuleType]='asynchronic online'))
GO
ALTER TABLE [dbo].[Modules] CHECK CONSTRAINT [CHK_Modules_ModuleType]
GO
ALTER TABLE [dbo].[Modules]  WITH CHECK ADD  CONSTRAINT [CHK_Modules_StartEndTime] CHECK  (([StartTime]<[EndTime]))
GO
ALTER TABLE [dbo].[Modules] CHECK CONSTRAINT [CHK_Modules_StartEndTime]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [CHK_Orders_Quantity] CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [CHK_Orders_Quantity]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [CHK_Payments_PaymentLink] CHECK  (([PaymentLink] like 'https://%.com'))
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [CHK_Payments_PaymentLink]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [CHK_Products_ProductType] CHECK  (([ProductType]='reunion' OR [ProductType]='course' OR [ProductType]='webinar'))
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [CHK_Products_ProductType]
GO
ALTER TABLE [dbo].[Reunions]  WITH CHECK ADD  CONSTRAINT [CHK_Reunions_EndDate] CHECK  (([EndDate]>[StartDate]))
GO
ALTER TABLE [dbo].[Reunions] CHECK CONSTRAINT [CHK_Reunions_EndDate]
GO
ALTER TABLE [dbo].[Roles]  WITH CHECK ADD  CONSTRAINT [CHK_Roles_RoleName] CHECK  (([RoleName]='WebinarParticipants' OR [RoleName]='CourseParticipants' OR [RoleName]='Students' OR [RoleName]='Participant' OR [RoleName]='Accounting' OR [RoleName]='Webinar Coordinator' OR [RoleName]='Study Coordinator' OR [RoleName]='Course Coordinator' OR [RoleName]='Secretariat' OR [RoleName]='Translator' OR [RoleName]='Lecturer' OR [RoleName]='Director' OR [RoleName]='Offer Coordinator' OR [RoleName]='System Administrator'))
GO
ALTER TABLE [dbo].[Roles] CHECK CONSTRAINT [CHK_Roles_RoleName]
GO
ALTER TABLE [dbo].[Semesters]  WITH CHECK ADD  CONSTRAINT [CHK_Semesters_EndDate] CHECK  (([EndDate]>[StartDate]))
GO
ALTER TABLE [dbo].[Semesters] CHECK CONSTRAINT [CHK_Semesters_EndDate]
GO
ALTER TABLE [dbo].[Semesters]  WITH CHECK ADD  CONSTRAINT [CHK_Semesters_SemesterType] CHECK  (([SemesterType]='winter' OR [SemesterType]='summer'))
GO
ALTER TABLE [dbo].[Semesters] CHECK CONSTRAINT [CHK_Semesters_SemesterType]
GO
ALTER TABLE [dbo].[Studies]  WITH CHECK ADD  CONSTRAINT [CHK_Studies_LinkToSyllabus] CHECK  (([LinkToSyllabus] like 'https://%.com'))
GO
ALTER TABLE [dbo].[Studies] CHECK CONSTRAINT [CHK_Studies_LinkToSyllabus]
GO
ALTER TABLE [dbo].[Studies]  WITH CHECK ADD  CONSTRAINT [CHK_Studies_SemesterCount] CHECK  (([SemesterCount]>(2)))
GO
ALTER TABLE [dbo].[Studies] CHECK CONSTRAINT [CHK_Studies_SemesterCount]
GO
ALTER TABLE [dbo].[StudyMeetings]  WITH CHECK ADD  CONSTRAINT [CHK_MeetingType] CHECK  (([MeetingType]='hybrid' OR [MeetingType]='stationary' OR [MeetingType]='synchronic online' OR [MeetingType]='asynchronic online'))
GO
ALTER TABLE [dbo].[StudyMeetings] CHECK CONSTRAINT [CHK_MeetingType]
GO
ALTER TABLE [dbo].[StudyMeetings]  WITH CHECK ADD  CONSTRAINT [CHK_StartTime_EndTime] CHECK  (([StartTime]<[EndTime]))
GO
ALTER TABLE [dbo].[StudyMeetings] CHECK CONSTRAINT [CHK_StartTime_EndTime]
GO
ALTER TABLE [dbo].[SynchronicOnlineModules]  WITH CHECK ADD  CONSTRAINT [CHK_MeetingLink_SyncOnlineMod] CHECK  (([MeetingLink] like 'https://%.com'))
GO
ALTER TABLE [dbo].[SynchronicOnlineModules] CHECK CONSTRAINT [CHK_MeetingLink_SyncOnlineMod]
GO
ALTER TABLE [dbo].[SynchronicOnlineStudyMeetings]  WITH CHECK ADD  CONSTRAINT [CHK_MeetingLink_SyncOnlineStudy] CHECK  (([MeetingLink] like 'https://%.com'))
GO
ALTER TABLE [dbo].[SynchronicOnlineStudyMeetings] CHECK CONSTRAINT [CHK_MeetingLink_SyncOnlineStudy]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [CHK_Email_Format] CHECK  (([Email] like '%@%'))
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [CHK_Email_Format]
GO
ALTER TABLE [dbo].[UsersAccounts]  WITH CHECK ADD CHECK  ((len([Password])>(7)))
GO
ALTER TABLE [dbo].[WebinarMeetings]  WITH CHECK ADD  CONSTRAINT [CHK_MeetingLink_WebinarMeetings] CHECK  (([MeetingLink] like 'https://%.com'))
GO
ALTER TABLE [dbo].[WebinarMeetings] CHECK CONSTRAINT [CHK_MeetingLink_WebinarMeetings]
GO
ALTER TABLE [dbo].[WebinarMeetings]  WITH CHECK ADD  CONSTRAINT [CHK_RecordingLink_WebinarMeetings] CHECK  (([RecordingLink] like 'https://%.com'))
GO
ALTER TABLE [dbo].[WebinarMeetings] CHECK CONSTRAINT [CHK_RecordingLink_WebinarMeetings]
GO
ALTER TABLE [dbo].[WebinarMeetings]  WITH CHECK ADD  CONSTRAINT [CHK_StartTime_EndTime_WebinarMeetings] CHECK  (([StartTime]<[EndTime]))
GO
ALTER TABLE [dbo].[WebinarMeetings] CHECK CONSTRAINT [CHK_StartTime_EndTime_WebinarMeetings]
GO
/****** Object:  StoredProcedure [dbo].[AddAsynchronicOnlineModule]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddAsynchronicOnlineModule]
    @ModuleID INT,
    @RecordingLink NVARCHAR(255),
    @ExpirationDate DATETIME
AS
BEGIN
    IF NOT @RecordingLink LIKE 'https://%.com'
    BEGIN
        RAISERROR ('RecordingLink nie spełnia wymagań formatu.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Modules] WHERE [ModuleID] = @ModuleID)
    BEGIN
        RAISERROR ('ModuleID nie istnieje.', 16, 1);
        RETURN;
    END

    INSERT INTO [dbo].[AsynchronicOnlineModules] (ModuleID, RecordingLink, ExpirationDate)
    VALUES (@ModuleID, @RecordingLink, @ExpirationDate);
END;

GO
/****** Object:  StoredProcedure [dbo].[AddCourse]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddCourse]
    @ProductID INT,
    @CourseName NVARCHAR(50),
    @StartDate DATETIME,
    @EndDate DATETIME,
    @Description NVARCHAR(MAX),
    @LanguageID INT
AS
BEGIN
    -- Sprawdzenie, czy data zakończenia jest późniejsza niż data rozpoczęcia kursu
    IF @EndDate <= @StartDate
    BEGIN
        RAISERROR ('Data zakończenia musi być późniejsza niż data rozpoczęcia.', 16, 1);
        RETURN;
    END

    -- Sprawdzenie, czy istnieje ProductID
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Products] WHERE [ProductID] = @ProductID)
    BEGIN
        RAISERROR ('ProductID nie istnieje.', 16, 1);
        RETURN;
    END

    -- Wstawienie nowego kursu do tabeli Courses
    INSERT INTO [dbo].[Courses] (ProductID, CourseName, StartDate, EndDate, Description, LanguageID)
    VALUES (@ProductID, @CourseName, @StartDate, @EndDate, @Description, @LanguageID);
END

GO
/****** Object:  StoredProcedure [dbo].[AddLocation]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddLocation]
    @CityID INT,
    @Street NVARCHAR(30),
    @Building INT,
    @Classroom INT,
    @PostalCode NVARCHAR(10),
    @Capacity INT 
AS 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Cities] WHERE [CityID] = @CityID)
    BEGIN
        RAISERROR ('CityID nie istnieje.', 16, 1);
        RETURN;
    END

    INSERT INTO [dbo].[Locations] (CityID, Street, Building, Classroom, PostalCode, Capacity)
    VALUES (@CityID, @Street, @Building, @Classroom, @PostalCode, @Capacity);
END;

GO
/****** Object:  StoredProcedure [dbo].[AddModule]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddModule]
    @CourseID INT,
    @LecturerID INT,
    @ModuleName NVARCHAR(50),
    @ModuleType NVARCHAR(20),
    @Date DATETIME,
    @StartTime TIME(7),
    @EndTime TIME(7)
AS
BEGIN
    IF @ModuleType NOT IN ('hybrid', 'stationary', 'synchronic online', 'asynchronic online')
    BEGIN
        RAISERROR ('Nieprawidłowy typ modułu.', 16, 1);
        RETURN;
    END

    IF @StartTime >= @EndTime
    BEGIN
        RAISERROR ('Czas rozpoczęcia musi być wcześniejszy niż czas zakończenia.', 16, 1);
        RETURN;
    END

    INSERT INTO [dbo].[Modules] (CourseID, LecturerID, ModuleName, ModuleType, Date, StartTime, EndTime)
    VALUES (@CourseID, @LecturerID, @ModuleName, @ModuleType, @Date, @StartTime, @EndTime);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddModuleInForeignLanguage]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddModuleInForeignLanguage]
    @LanguageID INT,
    @TranslatorID INT,
    @ModuleID INT 
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Languages] WHERE [LanguageID] = @LanguageID)
    BEGIN
        RAISERROR ('LanguageID nie istnieje.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Languages] WHERE [LanguageID] = @TranslatorID)
    BEGIN
        RAISERROR ('TranslatorID nie istnieje.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Modules] WHERE [ModuleID] = @ModuleID)
    BEGIN
        RAISERROR ('ModuleID nie istnieje.', 16, 1);
        RETURN;
    END

    INSERT INTO [dbo].[ModulesInForeignLanguages] (LanguageID, TranslatorID, ModuleID)
    VALUES (@LanguageID, @TranslatorID, @ModuleID);
END
GO
/****** Object:  StoredProcedure [dbo].[AddModuleNew]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddModuleNew]
    @CourseID INT,
    @LecturerID INT,
    @ModuleName NVARCHAR(50),
    @ModuleType NVARCHAR(20),
    @Date DATETIME,
    @StartTime TIME,
    @EndTime TIME,
    @LocationID INT = NULL,              -- Dla modułów offline
    @MaxParticipants INT = NULL,         -- Dla modułów offline
    @MeetingLink NVARCHAR(255) = NULL,   -- Dla synchronicznych modułów online
    @RecordingLink NVARCHAR(255) = NULL, -- Dla asynchronicznych modułów online
    @ExpirationDate DATETIME = NULL      -- Dla asynchronicznych modułów online
AS
BEGIN
    -- Dodajemy podstawowe informacje o module
    INSERT INTO [dbo].[Modules] (CourseID, LecturerID, ModuleName, ModuleType, Date, StartTime, EndTime)
    VALUES (@CourseID, @LecturerID, @ModuleName, @ModuleType, @Date, @StartTime, @EndTime);

    DECLARE @ModuleID INT = SCOPE_IDENTITY();

    -- Logika dla różnych typów modułów
    IF @ModuleType = 'asynchronic online'
    BEGIN
        INSERT INTO [dbo].[AsynchronicOnlineModules] (ModuleID, RecordingLink, ExpirationDate)
        VALUES (@ModuleID, @RecordingLink, @ExpirationDate);
    END
    ELSE IF @ModuleType = 'synchronic online'
    BEGIN
        INSERT INTO [dbo].[SynchronicOnlineModules] (ModuleID, MeetingLink)
        VALUES (@ModuleID, @MeetingLink);
    END
    ELSE IF @ModuleType = 'stationary'
    BEGIN
        INSERT INTO [dbo].[OfflineModules] (ModuleID, MaxParticipants, LocationID)
        VALUES (@ModuleID, @MaxParticipants, @LocationID);
    END
END

GO
/****** Object:  StoredProcedure [dbo].[AddOfflineModule]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddOfflineModule]
    @ModuleID INT,
    @MaxParticipants INT,
    @LocationID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Modules] WHERE [ModuleID] = @ModuleID)
    BEGIN
        RAISERROR ('ModuleID nie istnieje.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Locations] WHERE [LocationID] = @LocationID)
    BEGIN
        RAISERROR ('LocationID nie istnieje.', 16, 1);
        RETURN;
    END

    INSERT INTO [dbo].[OfflineModules] (ModuleID, MaxParticipants, LocationID)
    VALUES (@ModuleID, @MaxParticipants, @LocationID);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddProduct]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddProduct]
    @ProductType NVARCHAR(20),
    @ProductPrice MONEY,
    @ProductID INT OUTPUT
AS
BEGIN
    -- Sprawdzanie, czy typ produktu jest zgodny z ograniczeniem
    IF @ProductType NOT IN ('reunion', 'course', 'webinar')
    BEGIN
        RAISERROR ('Nieprawidłowy typ produktu', 16, 1);
        RETURN;
    END

    -- Wstawianie nowego wiersza do tabeli
    INSERT INTO [dbo].[Products] (ProductType, ProductPrice)
    VALUES (@ProductType, @ProductPrice);

    -- Zwracanie ID nowo dodanego produktu
    SET @ProductID = SCOPE_IDENTITY();
END
GO
/****** Object:  StoredProcedure [dbo].[AddReunion]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddReunion]
    @SemesterID INT,
    @ProductID INT,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @MaxStudents INT,
    @MaxOtherParticipants INT = NULL,
    @NewReunionID INT OUTPUT
AS
BEGIN
    -- Sprawdzenie poprawności dat
    IF @EndDate <= @StartDate
    BEGIN
        RAISERROR ('Data zakończenia musi być późniejsza niż data rozpoczęcia.', 16, 1);
        RETURN;
    END

    -- Sprawdzenie, czy ProductID istnieje w tabeli Products
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Products] WHERE ProductID = @ProductID)
    BEGIN
        RAISERROR ('Podany ProductID nie istnieje.', 16, 1);
        RETURN;
    END

    -- Sprawdzenie, czy SemesterID istnieje w tabeli Semesters
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Semesters] WHERE SemesterID = @SemesterID)
    BEGIN
        RAISERROR ('Podany SemesterID nie istnieje.', 16, 1);
        RETURN;
    END

    -- Dodanie informacji o spotkaniu do tabeli Reunions
    INSERT INTO [dbo].[Reunions] (SemesterID, ProductID, StartDate, EndDate, MaxStudents, MaxOtherParticipants)
    VALUES (@SemesterID, @ProductID, @StartDate, @EndDate, @MaxStudents, @MaxOtherParticipants);

    -- Ustawienie identyfikatora nowo utworzonego spotkania
    SET @NewReunionID = SCOPE_IDENTITY();
END;
GO
/****** Object:  StoredProcedure [dbo].[AddStudy]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddStudy]
    @StudyName NVARCHAR(50),
    @StudyType NVARCHAR(20),
    @SemesterCount INT,
    @MaxStudents INT,
    @LinkToSyllabus NVARCHAR(255),
    @Description NVARCHAR(MAX),
    @NewStudyID INT OUTPUT
AS
BEGIN
    -- Sprawdzenie poprawności danych wejściowych
    IF @SemesterCount <= 2
    BEGIN
        RAISERROR ('Liczba semestrów musi być większa niż 2.', 16, 1);
        RETURN;
    END

    IF NOT @LinkToSyllabus LIKE 'https://%.com'
    BEGIN
        RAISERROR ('Link do sylabusa jest nieprawidłowy.', 16, 1);
        RETURN;
    END

    -- Dodanie informacji o studiach do tabeli Studies
    INSERT INTO [dbo].[Studies] (StudyName, StudyType, SemesterCount, MaxStudents, LinkToSyllabus, Description)
    VALUES (@StudyName, @StudyType, @SemesterCount, @MaxStudents, @LinkToSyllabus, @Description);

    -- Ustawienie identyfikatora nowo utworzonych studiów
    SET @NewStudyID = SCOPE_IDENTITY();
END;
GO
/****** Object:  StoredProcedure [dbo].[AddSubject]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddSubject]
    @SemesterID INT,
    @SubjectName NVARCHAR(30),
    @Description NVARCHAR(MAX),
    @NewSubjectID INT OUTPUT
AS
BEGIN
    -- Sprawdzenie, czy SemesterID istnieje w tabeli Semesters
    IF @SemesterID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[Semesters] WHERE SemesterID = @SemesterID)
    BEGIN
        RAISERROR ('Podany SemesterID nie istnieje.', 16, 1);
        RETURN;
    END

    -- Dodanie informacji o przedmiocie do tabeli Subjects
    INSERT INTO [dbo].[Subjects] (SemesterID, SubjectName, Description)
    VALUES (@SemesterID, @SubjectName, @Description);

    -- Ustawienie identyfikatora nowo utworzonego przedmiotu
    SET @NewSubjectID = SCOPE_IDENTITY();
END;
GO
/****** Object:  StoredProcedure [dbo].[AddSynchronicOnlineModule]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddSynchronicOnlineModule]
    @ModuleID INT,
    @MeetingLink NVARCHAR(255)
AS
BEGIN
    IF NOT @MeetingLink LIKE 'https://%.com'
    BEGIN
        RAISERROR ('MeetingLink nie spełnia wymagań formatu.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Modules] WHERE [ModuleID] = @ModuleID)
    BEGIN
        RAISERROR ('ModuleID nie istnieje.', 16, 1);
        RETURN;
    END

    INSERT INTO [dbo].[SynchronicOnlineModules] (ModuleID, MeetingLink)
    VALUES (@ModuleID, @MeetingLink);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddUser]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddUser]
    @UserType NVARCHAR(30),
    @FirstName NVARCHAR(30),
    @LastName NVARCHAR(30),
    @Email NVARCHAR(100),
    @RoleID INT,
    @Login NVARCHAR(100),
    @Password NVARCHAR(30),
    @NewUserID INT OUTPUT
AS
BEGIN
    -- Sprawdzenie, czy email jest unikalny
    IF EXISTS (SELECT 1 FROM [dbo].[Users] WHERE Email = @Email)
    BEGIN
        RAISERROR ('Podany email już istnieje w bazie danych.', 16, 1);
        RETURN;
    END

    -- Sprawdzenie, czy login jest unikalny
    IF EXISTS (SELECT 1 FROM [dbo].[UsersAccounts] WHERE Login = @Login)
    BEGIN
        RAISERROR ('Podany login już istnieje w bazie danych.', 16, 1);
        RETURN;
    END

    -- Dodanie użytkownika do tabeli Users
    INSERT INTO [dbo].[Users] (UserType, FirstName, LastName, Email, RoleID)
    VALUES (@UserType, @FirstName, @LastName, @Email, @RoleID);

    -- Pobranie UserID dla nowo utworzonego użytkownika
    SET @NewUserID = SCOPE_IDENTITY();

    -- Dodanie konta użytkownika do tabeli UsersAccounts
    INSERT INTO [dbo].[UsersAccounts] (Login, Password, UserID)
    VALUES (@Login, @Password, @NewUserID);
END;

GO
/****** Object:  StoredProcedure [dbo].[AddWebinar]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddWebinar]
    @WebinarName NVARCHAR(50),
    @Description NVARCHAR(MAX),
    @ProductID INT,
    @LanguageID INT,
    @NewWebinarID INT OUTPUT
AS
BEGIN
    -- Sprawdzenie, czy ProductID i LanguageID istnieją w odpowiednich tabelach
    IF @ProductID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[Products] WHERE ProductID = @ProductID)
    BEGIN
        RAISERROR ('Podany ProductID nie istnieje.', 16, 1);
        RETURN;
    END

    IF @LanguageID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [dbo].[Languages] WHERE LanguageID = @LanguageID)
    BEGIN
        RAISERROR ('Podany LanguageID nie istnieje.', 16, 1);
        RETURN;
    END

    -- Dodanie informacji o webinarze do tabeli Webinars
    INSERT INTO [dbo].[Webinars] (WebinarName, Description, ProductID, LanguageID)
    VALUES (@WebinarName, @Description, @ProductID, @LanguageID);

    -- Ustawienie identyfikatora nowo utworzonego webinaru
    SET @NewWebinarID = SCOPE_IDENTITY();
END;
GO
/****** Object:  StoredProcedure [dbo].[AddWebinarMeeting]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddWebinarMeeting]
    @WebinarID INT,
    @LecturerID INT,
    @Date DATETIME,
    @StartTime TIME,
    @EndTime TIME,
    @MeetingLink NVARCHAR(255),
    @RecordingLink NVARCHAR(255),
    @NewWebinarMeetingID INT OUTPUT
AS
BEGIN
    -- Obliczenie ExpirationDate jako 30 dni od StartTime
    DECLARE @ExpirationDate DATETIME = DATEADD(DAY, 30, @Date);

    -- Sprawdzenie, czy WebinarID i LecturerID istnieją w odpowiednich tabelach
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Webinars] WHERE WebinarID = @WebinarID)
    BEGIN
        RAISERROR ('Podany WebinarID nie istnieje.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[Lecturers] WHERE LecturerID = @LecturerID)
    BEGIN
        RAISERROR ('Podany LecturerID nie istnieje.', 16, 1);
        RETURN;
    END

    -- Dodanie informacji o spotkaniu webinaru do tabeli WebinarMeetings
    INSERT INTO [dbo].[WebinarMeetings] (WebinarID, LecturerID, Date, StartTime, EndTime, MeetingLink, RecordingLink, ExpirationDate)
    VALUES (@WebinarID, @LecturerID, @Date, @StartTime, @EndTime, @MeetingLink, @RecordingLink, @ExpirationDate);

    -- Ustawienie identyfikatora nowo utworzonego spotkania webinaru
    SET @NewWebinarMeetingID = SCOPE_IDENTITY();
END;
GO
/****** Object:  StoredProcedure [dbo].[AssignTranslatorToModule]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AssignTranslatorToModule]
    @ModuleID INT
AS
BEGIN
    DECLARE @CourseLanguageID INT, @Date DATETIME, @StartTime TIME, @EndTime TIME;

    -- Pobierz LanguageID kursu i sprawdź, czy jest różne od 1 (polski)
    SELECT @CourseLanguageID = c.LanguageID
    FROM [dbo].[Courses] c
    JOIN [dbo].[Modules] m ON c.CourseID = m.CourseID
    WHERE m.ModuleID = @ModuleID AND c.LanguageID <> 1;

    IF @CourseLanguageID IS NOT NULL
    BEGIN
        -- Pobierz datę i godziny modułu
        SELECT @Date = Date, @StartTime = StartTime, @EndTime = EndTime
        FROM [dbo].[Modules]
        WHERE ModuleID = @ModuleID;

        -- Znajdź dostępnego tłumacza
        DECLARE @TranslatorID INT;
        SELECT TOP 1 @TranslatorID = t.TranslatorID
        FROM [dbo].[Translators] t
        WHERE t.LanguageID = @CourseLanguageID
          AND dbo.IsTranslatorAvailable(t.TranslatorID, @Date, @StartTime, @EndTime) = 1;

        -- Jeśli tłumacz jest dostępny, przypisz go do modułu
        IF @TranslatorID IS NOT NULL
        BEGIN
            INSERT INTO [dbo].[ModulesInForeignLanguages] (LanguageID, TranslatorID, ModuleID)
            VALUES (@CourseLanguageID, @TranslatorID, @ModuleID);
        END
        ELSE
        BEGIN
            -- Tłumacz nie jest dostępny, podejmij odpowiednie działania
            RAISERROR ('Brak dostępnego tłumacza dla wybranego modułu i języka.', 16, 1);
        END
    END
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateAsynchronicOnlineModule]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateAsynchronicOnlineModule]
    @AsynchronicOnlineModuleID INT,
    @NewRecordingLink NVARCHAR(255),
    @NewExpirationDate DATETIME
AS
BEGIN
    -- Sprawdzenie, czy podany RecordingLink jest poprawny
    IF NOT @NewRecordingLink LIKE 'https://%.com'
    BEGIN
        RAISERROR ('RecordingLink nie spełnia wymagań formatu.', 16, 1);
        RETURN;
    END

    -- Sprawdzenie, czy AsynchronicOnlineModuleID istnieje
    IF NOT EXISTS (SELECT 1 FROM [dbo].[AsynchronicOnlineModules] WHERE [AsynchronicOnlineModuleID] = @AsynchronicOnlineModuleID)
    BEGIN
        RAISERROR ('AsynchronicOnlineModuleID nie istnieje.', 16, 1);
        RETURN;
    END

    -- Aktualizowanie RecordingLink i ExpirationDate dla danego AsynchronicOnlineModuleID
    UPDATE [dbo].[AsynchronicOnlineModules]
    SET [RecordingLink] = @NewRecordingLink,
        [ExpirationDate] = @NewExpirationDate
    WHERE [AsynchronicOnlineModuleID] = @AsynchronicOnlineModuleID;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateMeetingLinkToSynchronicOnlineModule]    Script Date: 23.02.2024 15:12:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateMeetingLinkToSynchronicOnlineModule] 
    @SynchronicOnlineModuleID INT,
    @NewMeetingLink NVARCHAR(255)
AS
BEGIN
    IF NOT @NewMeetingLink LIKE 'https://%.com'
    BEGIN
        RAISERROR ('MeetingLink nie spełnia wymagań formatu.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM [dbo].[SynchronicOnlineModules] WHERE [SynchronicOnlineModuleID] = @SynchronicOnlineModuleID)
    BEGIN
        RAISERROR ('SynchronicOnlineModuleID nie istnieje.', 16, 1);
        RETURN;
    END

    UPDATE [dbo].[SynchronicOnlineModules]
    SET [MeetingLink] = @NewMeetingLink
    WHERE [SynchronicOnlineModuleID] = @SynchronicOnlineModuleID;
END;
GO
USE [master]
GO
ALTER DATABASE [u_bmarcini] SET  READ_WRITE 
GO
