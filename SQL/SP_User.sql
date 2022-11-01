USE [Servicios];
GO

--Inserta en la tabla Usuario
CREATE PROCEDURE dbo.CreateUser
    @inValDoc INT,
	@inUsername VARCHAR(32),
    @inPassword VARCHAR(32),
	@inUserType INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';


		--Revisa si hay algún parámentro de entrada nulo
		IF (@inUsername IS NULL OR LEN(@inUsername) = 0
			OR @inPassword IS NULL OR LEN(@inPassword) = 0
			OR @inValDoc IS NULL OR @inValDoc = 0
			OR @inUserType IS NULL OR @inUserType = 0)
		BEGIN
			SET @outResultCode = 50001;
			SET @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,	--Notifica a la web del error
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Si hay un usuario con mismo username
		IF EXISTS (SELECT 1 FROM dbo.Usuario WHERE Username = @inUsername)
		BEGIN
			SET @outResultCode = 50002;
			SET  @outResultMessage = 'Username ya existente';
			SELECT  @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Si hay un usuario con mismo IdPersona
		IF EXISTS (SELECT 1 FROM dbo.Usuario AS U
					INNER JOIN dbo.Persona AS P ON P.Id = U.IdPersona
					WHERE P.ValorDocumentoIdentidad = @inValDoc) --Si hay un usuario con mismo username
		BEGIN
			SET @outResultCode = 50003;
			SET  @outResultMessage = 'La persona ya tiene un usuario';
			SELECT  @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		INSERT INTO dbo.Usuario(
			IdPersona,
			Username,
			Password,
			TipoUsuario)
			SELECT P.Id,	--Pasa el Id de la persona con la identificación buscada
				@inUsername,
				@inPassword,
				@inUserType
				FROM dbo.Persona AS P 
				WHERE P.ValorDocumentoIdentidad = @inValDoc; 
			
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage; --Envia a la web el código
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

--Seleccionade la tabla Usuario
CREATE PROCEDURE dbo.ReadUser
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT U.Id,
		U.IdPersona,
		U.Username,
		U.Password,
		U.TipoUsuario,
		U.Activo
	FROM dbo.Usuario AS U; 

	SET NOCOUNT OFF;
END
GO

--Busca un usuario por Username
CREATE PROCEDURE dbo.SearchUser
	@inUsername VARCHAR(32),
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';
	
	IF (@inUsername IS NULL OR LEN(@inUsername) = 0)
	BEGIN
		SET @outResultCode = 50001;
		SET  @outResultMessage = 'Parámetros nulos';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	SELECT U.Id,
		U.IdPersona,
		U.Username,
		U.Password,
		U.TipoUsuario,
		U.Activo,
		@outResultCode,
		@outResultMessage
	FROM dbo.Usuario AS U
	WHERE U.Username = @inUsername; 
	SET NOCOUNT OFF;
END
GO

--Busca un usuario por su username y actualiza los valores solicitados
CREATE PROCEDURE dbo.UpdateUser
	@inUsername VARCHAR(32),
	@inNewUsername VARCHAR(32),
	@inNewPassword VARCHAR(32),
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		IF (@inUsername IS NULL OR LEN(@inUsername) = 0)
		BEGIN	-- Si no existe un usuario con el username buscado
			SET @outResultCode = 50001;
			SET @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		IF NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE Username = @inUsername)
		BEGIN	-- Si no existe un usuario con el username buscado
			SET @outResultCode = 50004;
			SET @outResultMessage = 'No existe el usuario';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;
		
		--Actualiza el password si se ingresó un nuevo valor
		IF (LEN(@inNewPassword) > 0)
		BEGIN
			UPDATE dbo.Usuario
				SET Password = @inNewPassword
				WHERE Username = @inUsername;
		END;

		--Actualiza el username si se ingresó un nuevo valor que no exista ya en la tabla usuarios
		IF (LEN(@inNewUsername) > 0
			AND NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE Username = @inNewUsername))
		BEGIN
			UPDATE dbo.Usuario
			SET Username = @inNewUsername
			WHERE Username = @inUsername;
		END;
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
END
GO




--Encuentra un usuario por nombre y cambia el valor de activo a 0
CREATE PROCEDURE dbo.DeleteUser
	@inUsername VARCHAR(32),
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		IF (@inUsername IS NULL OR LEN(@inUsername) = 0)
		BEGIN	-- Si no existe un usuario con el username buscado
			SET @outResultCode = 50001;
			SET @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		IF NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE Username = @inUsername)
		BEGIN
			SET @outResultCode = 50004;
			SET @outResultMessage = 'No existe el usuario';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		UPDATE dbo.Usuario
			SET Activo = 0
			WHERE Username = @inUsername;

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
	SET  NOCOUNT OFF;
END
GO
