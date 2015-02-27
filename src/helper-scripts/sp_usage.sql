USE [MASTER]
GO
IF OBJECT_ID('sp_usage') IS NOT NULL
	DROP PROCEDURE sp_usage
GO

CREATE PROCEDURE sp_usage
@Keyword sysname
AS 
--DECLARE @Keyword VARCHAR(100) = 'userdetail'
BEGIN

	SELECT 'Object with Keyword: ' + Name + REPLACE(REPLACE('(##OBJID##, ##TYPE##)','##OBJID##',CONVERT(VARCHAR(100),Object_id)),'##TYPE##',type_desc) COLLATE  SQL_Latin1_General_CP1_CI_AS AS Objects
	FROM sys.objects where name like '%' + @Keyword + '%'
	UNION ALL
	SELECT 'Columns with Keyword: ' + Name + REPLACE(REPLACE('(##TBL##, ##TYPE##)','##TBL##',OBJECT_NAME(Object_id)),'##TYPE##',TYPE_NAME(system_type_id)) AS Table_Columns
	FROM sys.columns where name like '%' + @Keyword + '%'
	UNION ALL
	SELECT 'Keyword found in Procedure: ' + object_name(object_id) AS Procedure_Text
	FROM sys.sql_modules 
	WHERE [definition] LIKE '%' + @Keyword + '%'
	ORDER BY 1
END
GO
EXEC sp_ms_marksystemobject 'sp_usage' 
