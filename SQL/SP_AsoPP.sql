USE [Servicios];
GO

--Para el portal de administrador, crea una asociación entre persona/propiedad
CREATE PROCEDURE dbo.CreateAsoPP
	@inDocVal INT,
	@inNumFinca INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa'

		--Revisa si hay algun parámetro de entrada nulo
		IF (@inDocVal IS NULL OR @inDocVal <= 0
			OR @inNumFinca IS NULL OR @inNumFinca <= 0)
		BEGIN
			SET @outResultCode = 50001;
			SET  @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Verifica si ya existe una relación sin fecha de fin entre la propiedad y la persona 
		IF EXISTS (SELECT 1 
				FROM dbo.PersonaXPropiedad PP
				INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
				INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad
				WHERE PE.ValorDocumentoIdentidad = @inDocVal
					AND PR.NumeroFinca = @inNumFinca
					AND PP.FechaFin IS NULL)
		BEGIN
			SET @outResultCode = 50009;
			SET  @outResultMessage = 'Ya existe una relación activa entre la persona y la propiedad';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		INSERT INTO dbo.PersonaXPropiedad(
			[IdPersona],
			[IdPropiedad],
			[FechaInicio])
			SELECT PE.Id,
				PR.Id,
				GETDATE()
			FROM dbo.Persona AS PE,
				dbo.Propiedad AS PR
			WHERE PE.ValorDocumentoIdentidad = @inDocVal
				AND PR.NumeroFinca = @inNumFinca;
	END TRY
	BEGIN CATCH
		INSERT dbo.DBErrors
		VALUES (
			SUSER_NAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			);
		SET @outResultCode = 50050;
		SET @outResultMessage = 'Fallo del sistema';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
	END CATCH
	SELECT @outResultCode AS ResultCode,
		@outResultMessage AS ResultMessage;

	SET NOCOUNT OFF;
END;
GO

--Para el portal de administrador, lee todas las asociaciones persona/propiedad
CREATE PROCEDURE dbo.ReadAsoPP
AS
BEGIN
	SET NOCOUNT ON;
	SELECT PP.Id,
		PE.ValorDocumentoIdentidad AS IdentificacionPersona,
		PR.NumeroFinca,
		CAST(PP.FechaInicio  AS VARCHAR(16)) AS FechaInicio,
		CAST(PP.FechaFin  AS VARCHAR(16)) AS FechaFin
	FROM dbo.PersonaXPropiedad AS PP
	INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
	INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad;

	SET NOCOUNT OFF;
END;
GO

--Para el portal de administrador, actualiza la fecha inicio de una asociación persona/propiedad
CREATE PROCEDURE dbo.UpdateAsoPP
	@inDocVal INT,
	@inNumFinca INT,
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa'

		--Revisa si hay algun parámetro de entrada nulo
		IF (@inDocVal IS NULL OR @inDocVal <= 0
			OR @inNumFinca IS NULL OR @inNumFinca <= 0
			OR @inDate IS NULL OR LEN(@inDate) = 0)
		BEGIN
			SET @outResultCode = 50001;
			SET  @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Verifica si existe una relación entre la propiedad y la persona 
		IF NOT EXISTS (SELECT 1 
				FROM dbo.PersonaXPropiedad PP
				INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
				INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad
				WHERE PE.ValorDocumentoIdentidad = @inDocVal
					AND PR.NumeroFinca = @inNumFinca)
		BEGIN
			SET @outResultCode = 50014;
			SET  @outResultMessage = 'No existe una relación entre la persona y la propiedad';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		Update dbo.PersonaXPropiedad
			SET FechaInicio = @inDate
			FROM dbo.PersonaXPropiedad AS PP
			INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
			INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad
			WHERE PE.ValorDocumentoIdentidad = @inDocVal
				AND PR.NumeroFinca = @inNumFinca;

		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
	END TRY
	BEGIN CATCH
		INSERT dbo.DBErrors
		VALUES (
			SUSER_NAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			);
		SET @outResultCode = 50050;
		SET @outResultMessage = 'Fallo del sistema';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
	END CATCH
	SET NOCOUNT OFF;
END;
GO

--Para el portal de administrador, actualiza la fecha fin de una asociación persona/propiedad
CREATE PROCEDURE dbo.DeleteAsoPP
	@inDocVal INT,
	@inNumFinca INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa'

		--Revisa si hay algun parámetro de entrada nulo
		IF (@inDocVal IS NULL OR @inDocVal <= 0
			OR @inNumFinca IS NULL OR @inNumFinca <= 0)
		BEGIN
			SET @outResultCode = 50001;
			SET  @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Verifica si existe una relación activa entre la propiedad y la persona 
		IF NOT EXISTS (SELECT 1 
				FROM dbo.PersonaXPropiedad PP
				INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
				INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad
				WHERE PE.ValorDocumentoIdentidad = @inDocVal
					AND PR.NumeroFinca = @inNumFinca
					AND PP.FechaFin IS NULL)
		BEGIN
			SET @outResultCode = 50011;
			SET  @outResultMessage = 'No existe una relación activa entre la persona y la propiedad';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		Update dbo.PersonaXPropiedad
			SET FechaFin = GETDATE()
			FROM dbo.PersonaXPropiedad AS PP
			INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
			INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad
			WHERE PE.ValorDocumentoIdentidad = @inDocVal
				AND PR.NumeroFinca = @inNumFinca;

		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
	END TRY
	BEGIN CATCH
		INSERT dbo.DBErrors
		VALUES (
			SUSER_NAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			);
		SET @outResultCode = 50050;
		SET @outResultMessage = 'Fallo del sistema';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
	END CATCH
	SET NOCOUNT OFF;
END;
GO