USE [u_bmarcini]
GO
/****** Object:  StoredProcedure [dbo].[AddAsynchronicOnlineModule]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddCourse]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddLocation]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddModule]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddModuleInForeignLanguage]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddModuleNew]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddOfflineModule]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddProduct]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddReunion]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddStudy]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddSubject]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddSynchronicOnlineModule]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddUser]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddWebinar]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AddWebinarMeeting]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[AssignTranslatorToModule]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateAsynchronicOnlineModule]    Script Date: 23.02.2024 15:06:57 ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateMeetingLinkToSynchronicOnlineModule]    Script Date: 23.02.2024 15:06:57 ******/
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
