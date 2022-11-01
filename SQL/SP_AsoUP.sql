USE [Servicios];
GO

--Para administradores, crea una asociación usuario/propiedad
CREATE PROCEDURE dbo.CreateAsoUP
	@inUsername VARCHAR(32),
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
		IF (@inUsername IS NULL OR LEN(@inUsername) = 0
			OR @inNumFinca IS NULL OR @inNumFinca <= 0)
		BEGIN
			SET @outResultCode = 50001;
			SET  @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Verifica si ya existe una relación sin fecha de fin entre la propiedad y usuario
		IF EXISTS (SELECT 1 
				FROM dbo.UsuarioXPropiedad UP
				INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
				INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad
				WHERE U.Username = @inUsername
					AND PR.NumeroFinca = @inNumFinca
					AND UP.FechaFin IS NULL)
		BEGIN
			SET @outResultCode = 50012;
			SET  @outResultMessage = 'Ya existe una relación activa entre el ususario y la propiedad';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		INSERT INTO dbo.UsuarioXPropiedad(
			[IdUsuario],
			[IdPropiedad],
			[FechaInicio])
			SELECT U.Id,
				PR.Id,
				GETDATE()
			FROM dbo.Usuario AS U,
				dbo.Propiedad AS PR
			WHERE U.Username = @inUsername
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

--Para administradores, lee todas las asociaciones usuario/propiedad
CREATE PROCEDURE dbo.ReadAsoUP
AS
BEGIN
	SET NOCOUNT ON;
	SELECT UP.Id,
		U.Username,
		PR.NumeroFinca,
		CAST(UP.FechaInicio  AS VARCHAR(16)) AS FechaInicio,
		CAST(UP.FechaFin  AS VARCHAR(16)) AS FechaFin
	FROM dbo.UsuarioXPropiedad AS UP
	INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
	INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad;

	SET NOCOUNT OFF;
END;
GO

--Cambia la fecha de una asociación usuario/propiedad, para administradores
CREATE PROCEDURE dbo.UpdateAsoUP
	@inUsername VARCHAR(32),
	@inNumFinca INT,
	@inNewDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa'

		--Revisa si hay algun parámetro de entrada nulo
		IF (@inUsername IS NULL OR LEN(@inUsername) = 0
			OR @inNumFinca IS NULL OR @inNumFinca <= 0
			OR @inNewDate IS NULL OR LEN(@inNewDate) = 0)
		BEGIN
			SET @outResultCode = 50001;
			SET  @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Verifica si existe una relación activa entre la propiedad y usuario
		IF NOT EXISTS (SELECT 1 
				FROM dbo.UsuarioXPropiedad UP
				INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
				INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad
				WHERE U.Username = @inUsername
					AND PR.NumeroFinca = @inNumFinca)
		BEGIN
			SET @outResultCode = 50015;
			SET  @outResultMessage = 'No existe una relación entre la persona y la propiedad';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		Update dbo.UsuarioXPropiedad
			SET FechaInicio = @inNewDate
			FROM dbo.UsuarioXPropiedad AS UP
			INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
			INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad
			WHERE U.Username = @inUsername
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

--Para administradores, actualiza la fecha fin de una asociación usuario/propiedad
CREATE PROCEDURE dbo.DeleteAsoUP
	@inUsername VARCHAR(32),
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
		IF (@inUsername IS NULL OR LEN(@inUsername) = 0
			OR @inNumFinca IS NULL OR @inNumFinca <= 0)
		BEGIN
			SET @outResultCode = 50001;
			SET  @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Verifica si existe una relación activa entre la propiedad y usuario
		IF NOT EXISTS (SELECT 1 
				FROM dbo.UsuarioXPropiedad UP
				INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
				INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad
				WHERE U.Username = @inUsername
					AND PR.NumeroFinca = @inNumFinca
					AND UP.FechaFin IS NULL)
		BEGIN
			SET @outResultCode = 50013;
			SET  @outResultMessage = 'No existe una relación activa entre la persona y la propiedad';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		Update dbo.UsuarioXPropiedad
			SET FechaFin = GETDATE()
			FROM dbo.UsuarioXPropiedad AS UP
			INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
			INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad
			WHERE U.Username = @inUsername
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

