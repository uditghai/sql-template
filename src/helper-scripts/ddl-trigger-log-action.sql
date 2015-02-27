
/*

CREATE TABLE [dbo].[Audit_DDL_Event_Log](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[EventType] [varchar](100) NULL,
	[EventTime] [datetime] NULL,
	[ObjectName] [varchar](255) NULL,
	[HostClient] [varchar](255) NULL,
	[HostProgram] [varchar](255) NULL,
	[EventXML] [xml] NULL,
 CONSTRAINT [PK_Audit_DDL_Event_Log] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

*/

--DROP TRIGGER DDLTrigger_Restrict_Drop_Alter on database

CREATE TRIGGER DDLTrigger_Restrict_Drop_Alter
    ON DATABASE
    FOR ALTER_PROCEDURE, DROP_PROCEDURE, ALTER_TABLE,DROP_TABLE,CREATE_TABLE,RENAME
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @EventXML XML = EVENTDATA();
	INSERT INTO dbo.Audit_DDL_Event_Log
	SELECT 
		@EventXML.value('EVENT_INSTANCE[1]/EventType[1]','VARCHAR(255)') as EventType ,
		GETDATE() as EventTime ,
		@EventXML.value('EVENT_INSTANCE[1]/ObjectName[1]','VARCHAR(255)') as ObjectName,
		HOST_NAME(),
		PROGRAM_NAME(),
		@EventXML

END
GO

