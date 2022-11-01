USE [Servicios]
GO

--Selecciona el Id y tipo del usuario que coincide con el nombre y clave ingresados.
CREATE PROCEDURE dbo.FindUser
		@inName VARCHAR(32),
		@inClave VARCHAR(32),
		@outResultCode INT OUTPUT,
		@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		IF (@inName IS NULL OR LEN(@inName) = 0
			OR @inClave IS NULL OR LEN(@inName) = 0)
		BEGIN
			--Faltan parámetros
			SET @outResultCode = 50001;
			SET @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage
			RETURN;
		END;

		IF NOT EXISTS (SELECT 1 FROM dbo.Usuario U WHERE (@inName = U.Username AND @inClave = U.Password))
		BEGIN
			SET @outResultCode = 50010; --No existe el par Usuario-Clave.
			SET @outResultMessage = 'No existe el par Username-Password';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage
			RETURN;
		END;

		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage,
			U.Id,
			U.TipoUsuario
		FROM dbo.Usuario U
		WHERE (@inName = U.Username AND @inClave = U.Password);
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
END
GO

CREATE PROCEDURE dbo.ReadTiposDoc
AS
BEGIN
	SET NOCOUNT ON;
	SELECT T.Id,
		T.Nombre
		FROM dbo.TipoDocumentoIdentidad AS T;
	SET NOCOUNT OFF;
END;


--Inserta en la tabla Persona
CREATE PROCEDURE dbo.CreatePerson
	@inName VARCHAR(32),
	@inIdTipoDoc INT,
	@inValorDoc INT,
	@inEmail VARCHAR(64),
	@inTelefono1 INT,
	@inTelefono2 INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		--Revisa si hay algún parámentro de entrada nulo
		IF (@inName IS NULL OR LEN(@inName) = 0
			OR @inIdTipoDoc IS NULL OR @inIdTipoDoc = 0
			OR @inValorDoc IS NULL OR @inValorDoc = 0
			OR @inEmail IS NULL OR LEN(@inEmail) = 0
			OR @inTelefono1 IS NULL OR @inTelefono1 = 0
			OR @inTelefono2 IS NULL OR @inTelefono2 = 0)
		BEGIN
			SET @outResultCode = 50001;
			SET  @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		IF EXISTS (SELECT 1 FROM dbo.Persona WHERE ValorDocumentoIdentidad = @inValorDoc) --Si hay una persona con misma identificación
		BEGIN
			SET @outResultCode = 50002;
			SET  @outResultMessage = 'Persona con identificación repetida.';
			SELECT  @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		INSERT INTO dbo.Persona(
			IdTipoDocumentoIdentidad,
			ValorDocumentoIdentidad,
			Nombre,
			Email,
			Telefono1,
			Telefono2)
			SELECT @inIdTipoDoc,
				@inValorDoc,
				@inName,
				@inEmail,
				@inTelefono1,
				@inTelefono2;

		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage; --Envia el código de resultado a la web
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
END
GO

--Selecciona a todos de la tabla Persona
CREATE PROCEDURE dbo.ReadPerson
AS
BEGIN
	SET NOCOUNT ON;
	SELECT P.Id,
		P.IdTipoDocumentoIdentidad,
		P.ValorDocumentoIdentidad,
		P.Nombre,
		P.Email,
		P.Telefono1,
		P.Telefono2,
		P.Activo
	FROM dbo.Persona AS P; 
	SET NOCOUNT OFF;
END
GO

--Selecciona de la tabla Persona por identificación
CREATE PROCEDURE dbo.SearchPerson
	@inDocVal INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';
	
	IF (@inDocVal IS NULL OR @inDocVal = 0)
	BEGIN
		SET @outResultCode = 50001;
		SET  @outResultMessage = 'Parámetros nulos';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	SELECT P.Id,
		P.IdTipoDocumentoIdentidad,
		P.ValorDocumentoIdentidad,
		P.Nombre,
		P.Email,
		P.Telefono1,
		P.Telefono2,
		P.Activo,
		@outResultCode,
		@outResultMessage
	FROM dbo.Persona AS P
	WHERE ValorDocumentoIdentidad = @inDocVal; 
	SET NOCOUNT OFF;
END
GO

--Actualiza datos de una persona 
CREATE PROCEDURE dbo.UpdatePerson
	@inDocVal INT,
	@inNewName VARCHAR(32),
	@inNewEmail VARCHAR(64),
	@inNewTelefono1 INT,
	@inNewTelefono2 INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		--Revisa si la identificación es nula
		IF (@inDocVal IS NULL OR @inDocVal = 0)
		BEGIN
			SET @outResultCode = 50001;
			SET  @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Si no existe una persona con la identificación buscada
		IF NOT EXISTS (SELECT 1 FROM dbo.Persona WHERE ValorDocumentoIdentidad = @inDocVal)
		BEGIN
			SET @outResultCode = 50008;
			SET @outResultMessage = 'No existe la persona';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;
		BEGIN TRANSACTION tUpdatePerson
			--Actualiza el nombre si se ingresó un nuevo valor
			IF (LEN(@inNewName) > 0 AND @inNewName IS NOT NULL)
			BEGIN
				UPDATE dbo.Persona
					SET Nombre = @inNewName
					WHERE ValorDocumentoIdentidad = @inDocVal;
			END;

			--Actualiza el Email si se ingresó un nuevo valor
			IF (LEN(@inNewEmail) > 0 AND @inNewEmail IS NOT NULL)
			BEGIN
				UPDATE dbo.Persona
					SET Email = @inNewEmail
					WHERE ValorDocumentoIdentidad = @inDocVal;
			END;

			--Actualiza teléfono 1 si se ingresó un nuevo valor
			IF (@inNewTelefono1 IS NOT NULL AND @inNewTelefono1 > 0)
			BEGIN
				UPDATE dbo.Persona
					SET Telefono1 = @inNewTelefono1
					WHERE ValorDocumentoIdentidad = @inDocVal;
			END;

			--Actualiza teléfono 2 si se ingresó un nuevo valor
			IF (@inNewTelefono2 IS NOT NULL AND @inNewTelefono2 > 0)
			BEGIN
				UPDATE dbo.Persona
					SET Telefono2 = @inNewTelefono2
					WHERE ValorDocumentoIdentidad = @inDocVal;
			END;
		COMMIT TRANSACTION tUpdatePerson
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION tUpdatePerson;
		END;
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
END
GO

--Desactiva a una persona
CREATE PROCEDURE dbo.DeletePerson
	@inDocVal INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';
		
		--Si no existe una persona con la identificación buscada
		IF NOT EXISTS (SELECT 1 FROM dbo.Persona WHERE ValorDocumentoIdentidad = @inDocVal)
		BEGIN
			SET @outResultCode = 50008;
			SET @outResultMessage = 'No existe la persona';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		UPDATE dbo.Persona
			SET Activo = 0
			WHERE ValorDocumentoIdentidad = @inDocVal;

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

