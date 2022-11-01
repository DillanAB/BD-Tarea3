USE [Servicios];
GO

--Obtiene las propiedades de una persona por su # documento de identificación o por su nombre
CREATE PROCEDURE dbo.GetPropsFromPerson
	@inName VARCHAR(32),
	@inDocVal INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		--Revisa que al menos un parámetro haya sido ingresado
		IF ((@inDocVal IS NULL OR @inDocVal = 0)
			AND (@inName IS NULL OR LEN(@inName) = 0))
		BEGIN
			SET @outResultCode = 50001;
			SET @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,	--Para enviar el código a la web
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Si el parámetro de identificación no es nulo, lo usa para la selección
		IF (@inDocVal IS NOT NULL AND @inDocVal > 0) --La web envía un 0 si el campo es nulo por eso también verifica que no lo sea
		BEGIN
			SELECT TU.Nombre AS Uso,
				TZ.Nombre AS Zona,
				P.NumeroFinca,
				P.Area,
				P.ValorFiscal,
				P.NumeroMedidor,
				CAST(P.FechaRegistro AS VARCHAR(16)) AS FechaRegistro,
				P.Activo
			FROM dbo.PersonaXPropiedad AS PP
				INNER JOIN dbo.Propiedad AS P ON P.Id = PP.IdPropiedad	
				INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
				INNER JOIN dbo.TipoUsoPropiedad AS TU ON TU.Id = P.IdTipoUsoPropiedad
				INNER JOIN dbo.TipoZonaPropiedad AS TZ ON TZ.Id = P.IdTipoZonaPropiedad
			WHERE PE.ValorDocumentoIdentidad = @inDocVal;	--Selecciona los que tienen identificación ingresada
		END
		--Si el parámetro de identificación es nulo entonces selecciona con el nombre de la persona
		ELSE
		BEGIN
			SELECT TU.Nombre AS Uso,
			TZ.Nombre AS Zona,
			P.NumeroFinca,
			P.Area,
			P.ValorFiscal,
			P.NumeroMedidor,
			P.FechaRegistro,
			P.Activo
			FROM dbo.PersonaXPropiedad AS PP
				INNER JOIN dbo.Propiedad AS P ON P.Id = PP.IdPropiedad
				INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
				INNER JOIN dbo.TipoUsoPropiedad AS TU ON TU.Id = P.IdTipoUsoPropiedad
				INNER JOIN dbo.TipoZonaPropiedad AS TZ ON TZ.Id = P.IdTipoZonaPropiedad
			WHERE PE.Nombre = @inName; --Selecciona los que tienen el nombre ingresado
		END
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

--Obtiene los propietarios de una propiedad por su número de finca
CREATE PROCEDURE dbo.GetPropietarios
	@inNumFinca INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		IF (@inNumFinca IS NULL OR @inNumFinca = 0)
		BEGIN
			SET @outResultCode = 50001;
			SET @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode, --Pasa el error a la web
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		SELECT PE.ValorDocumentoIdentidad,
			PE.Nombre,
			PE.Activo,
			CAST(PP.FechaInicio AS VARCHAR(16)) AS FechaInicio, --Por problemas de compatibilidad con la web, las fechas se pasan como VARCHAR
			CAST(PP.FechaFin AS VARCHAR(16)) AS FechaFin
		FROM dbo.PersonaXPropiedad AS PP
			INNER JOIN dbo.Propiedad AS P ON P.Id = PP.IdPropiedad
			INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
		WHERE P.NumeroFinca = @inNumFinca; --Selecciona los que tienen el mismo número de finca
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

--Obtiene las propiedades que puede ver un usuario, busca por username
CREATE PROCEDURE dbo.GetPropsFromUser
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
		BEGIN
			SET @outResultCode = 50001;
			SET @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,	--Notifica a la web del error
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		SELECT TU.Nombre AS Uso,
			TZ.Nombre AS Zona,
			P.NumeroFinca,
			P.Area,
			P.ValorFiscal,
			P.NumeroMedidor,
			CAST(P.FechaRegistro AS VARCHAR(16)) AS FechaRegistro, --Por incompatibilidad de formatos con la web se castea la fecha como varchar
			P.Activo
		FROM dbo.UsuarioXPropiedad AS UP
			INNER JOIN dbo.Propiedad AS P ON P.Id = UP.IdPropiedad	
			INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
			INNER JOIN dbo.TipoUsoPropiedad AS TU ON TU.Id = P.IdTipoUsoPropiedad
			INNER JOIN dbo.TipoZonaPropiedad AS TZ ON TZ.Id = P.IdTipoZonaPropiedad
		WHERE U.Username = @inUsername;	--Selecciona los que tienen el username buscado
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

--Obtiene los usuarios que pueden ver una propiedad, busca por número de finca
CREATE PROCEDURE dbo.GetUsers
	@inNumFinca INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		IF (@inNumFinca IS NULL OR @inNumFinca = 0)
		BEGIN
			SET @outResultCode = 50001;
			SET @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,	--Notifica a la web del error
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		SELECT U.Username
		FROM dbo.UsuarioXPropiedad AS UP
			INNER JOIN dbo.Propiedad AS P ON P.Id = UP.IdPropiedad
			INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
		WHERE P.NumeroFinca = @inNumFinca; --Selecciona los que tienen el mismo número de finca
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
