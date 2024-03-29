USE [u_bmarcini]
GO
/****** Object:  View [dbo].[AttendanceRate]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[CertificatesToSend]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[CourseDebtors]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[CourseParticipantsPayments]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[CoursePassingStatus]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[CoursesAndModules]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[CoursesIncome]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[Debtors]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[DefferedPayments]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[FutureCourseParticipants]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[FutureParticipants]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[FutureStudyMeetingParticipants]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[FutureWebinarParticipants]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[IncomeSummary]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[LoginPassword]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[ModuleAttendanceList]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[ModulesLecturers]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[OverlappingMeetings]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[ReunionsIncome]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[StudentsInternships]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[StudentStudy]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[StudyMeetingAttendanceList]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[StudyMeetingLecturers]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[StudySubjects]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[WebinarAttendanceList]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[WebinarDebtors]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[WebinarLecturers]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[WebinarParticipantsPayments]    Script Date: 23.02.2024 15:01:45 ******/
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
/****** Object:  View [dbo].[WebinarsIncome]    Script Date: 23.02.2024 15:01:45 ******/
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
