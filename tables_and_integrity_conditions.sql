USE [u_bmarcini]
GO
/****** Object:  Table [dbo].[AsynchronicOnlineModules]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[AsynchronicOnlineStudyMeetings]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Cities]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Countries]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[CourseParticipants]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Courses]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[ExamResults]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Exams]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Internships]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Languages]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Lecturers]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Locations]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[ModuleAttendances]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Modules]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[ModulesInForeignLanguages]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[OfflineModules]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[OfflineStudyMeetings]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Orders]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Payments]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Products]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Reunions]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Roles]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Semesters]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Students]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Studies]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[StudyMeetingAttendances]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[StudyMeetings]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Subjects]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[SubjectsInForeignLanguages]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[SynchronicOnlineModules]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[SynchronicOnlineStudyMeetings]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Translators]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Users]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[UsersAccounts]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Voivodeships]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[WebinarAttendances]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[WebinarMeetings]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[WebinarParticipants]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[Webinars]    Script Date: 23.02.2024 13:19:26 ******/
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
/****** Object:  Table [dbo].[WebinarsInForeignLanguages]    Script Date: 23.02.2024 13:19:26 ******/
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
