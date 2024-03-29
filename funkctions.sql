USE [u_bmarcini]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateOrderTotal]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[CalculateTotalCourseDuration]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[CheckModuleAvailability]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[CheckRoomAvailability]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetActiveWebinarsCount]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetAverageCoursePrice]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetAverageReunionPrice]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetAverageWebinarPrice]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetCourseParticipantCount]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetMostPopularCourse]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetNumberOfCoursesByLecturer]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetNumberOfModulesInCourse]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetOrderCountForProduct]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetOverallAverageProductPrice]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetPaymentStatus]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetPendingPaymentsCountByUser]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetTotalStudentCount]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[HasOnlineModules]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[HasStudentPassedExam]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[HasStudentPendingPayments]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[IsLecturerAvailable]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[IsTranslatorAvailable]    Script Date: 23.02.2024 15:03:56 ******/
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
/****** Object:  UserDefinedFunction [dbo].[IsWebinarRecordingAvailable]    Script Date: 23.02.2024 15:03:56 ******/
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
