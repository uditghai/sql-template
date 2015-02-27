IF OBJECT_ID('<Procedure_Name, sysname, ProcedureName>') IS NOT NULL
	DROP PROCEDURE <Procedure_Name, sysname, ProcedureName>
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author, sysname, Author>
-- Create date:  YYY/MM/DD
-- Description:
-- =============================================
CREATE PROCEDURE <Procedure_Name, sysname, ProcedureName>
@Input1 VARCHAR(255),
@Input2 VARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @BeginTranCount INT = @@TRANCOUNT;
		IF @BeginTranCount = 0 BEGIN TRANSACTION
		ELSE SAVE TRANSACTION <Procedure_Name, sysname, ProcedureName>

	END TRY
	BEGIN CATCH
		--Rollback the transaction if any exists
		IF @@TRANCOUNT > @BeginTranCount AND XACT_STATE() = -1
		
		IF XACT_STATE() = -1
			ROLLBACK;
		IF XACT_STATE() = 1 AND @BeginTranCount = 0
			ROLLBACK;
		IF XACT_STATE() = 1 AND @BeginTranCount > 0
			ROLLBACK TRANSACTION  <Procedure_Name, sysname, ProcedureName>;

		-- Either Throw the error and exist or log the error in a table using a procedure

		--DECLARE ERROR VARIABLES
		DECLARE @ErrorMessage VARCHAR(2000)

		DECLARE @ErrorLine INT, @ErrorProc VARCHAR(500), @ErrorState INT,@ErrorSeverity INT, @ErrorStack VARCHAR(MAX)
		DECLARE @ErrorInput VARCHAR(2000) = 
			'Input1[' + CONVERT(VARCHAR(100),@Input1) + ']'
			+ ' Input2[' + CONVERT(VARCHAR(100),@Input2) +']';
		SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorLine = ERROR_LINE(),
			@ErrorProc = COALESCE(ERROR_PROCEDURE(),'[<Procedure_Name, sysname, ProcedureName>]'),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE(),
			@ErrorStack = 
				'Msg ' + CONVERT(VARCHAR(5),@ErrorLine) + ', ' +
				'Level ' + CONVERT(VARCHAR(5),@ErrorSeverity) + ', ' +
				'State ' + CONVERT(VARCHAR(5),@ErrorSeverity) + ', ' +
				'Line ' + CONVERT(VARCHAR(5),@ErrorLine) + ', ' +
				ISNULL('Proc ' + @ErrorProc + ', ','') +
				CHAR(10) + @ErrorMessage;

		--Log the Error
		EXEC dbo.usp_standard_logging_procedure
			@ErrorMessage = @ErrorMessage,
			@IsInfo = 0,
			@ErrorStack = @ErrorStack,
			@ErrorInput = @ErrorInput,
			@ErrorProcessInfo = @ErrorProc;

		--THROW the error
		THROW;
	END CATCH
END
GO
