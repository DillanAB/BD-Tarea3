USE [Servicios];
GO

--Inserta en la tabla Propiedad
CREATE PROCEDURE dbo.CreateProperty
	@inFincNum INT,
    @inUseType VARCHAR(32),
	@inZoneType VARCHAR(32),
    @inArea INT,
	@inFiscalValue BIGINT,
	@inMedNum INT,
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
		IF (@inUseType IS NULL OR LEN(@inUseType) = 0
			OR @inZoneType IS NULL OR LEN(@inZoneType) = 0
			OR @inFincNum = 0
			OR @inArea = 0
			OR @inFiscalValue = 0
			OR @inMedNum = 0
			OR @inDate IS NULL OR LEN(@inDate) = 0)
		BEGIN
			SET @outResultCode = 50001;
			SET  @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Reemplaza guiones por espacios para que coincida con los valores de la tabla TipoUsoPropiedad 
		SET @inUseType = REPLACE(@inUseType, N'-', N' ');
		--Reemplaza guiones por espacios para que coincida con los valores de la tabla TipoZonaPropiedad 
		SET @inZoneType = REPLACE(@inZoneType, N'-', N' ');

		--Si existe una propiedad con el mismo número de finca
		IF EXISTS (SELECT 1 FROM dbo.Propiedad P WHERE P.NumeroFinca = @inFincNum)
		BEGIN
			SET @outResultCode = 50005;
			SET  @outResultMessage = 'Ya existe una propiedad con el número de finca';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;
		BEGIN TRANSACTION tPropiedadXCC
			INSERT INTO dbo.Propiedad(
				IdTipoUsoPropiedad,
				IdTipoZonaPropiedad,
				NumeroFinca,
				Area,
				ValorFiscal,
				NumeroMedidor,
				FechaRegistro)
				SELECT DISTINCT TU.Id,
					TZ.Id,
					@inFincNum,
					@inArea,
					@inFiscalValue,
					@inMedNum,
					@inDate
				FROM dbo.TipoZonaPropiedad AS TZ,
					dbo.TipoUsoPropiedad AS TU
				WHERE TZ.Nombre = @inZoneType
					AND TU.Nombre = @inUseType;

				IF ( @inUseType <> 'Agricola')
				BEGIN 
					INSERT INTO dbo.PropiedadXConceptoCobro (
						IdPropiedad,
						IdConceptoCobro,
						FechaInicio)
					SELECT P.Id,
						C.Id,
						@inDate
					FROM dbo.Propiedad AS P,
						dbo.ConceptoCobro AS C
					WHERE P.NumeroFinca = @inFincNum
						AND C.Nombre = 'Recoleccion de basura';
				END;

				--Si es de área comercial o residencial se agrega el servicio: Mantenimiento de parques
				IF ( @inZoneType = 'Residencial'
					OR @inZoneType = 'Zona comercial')
				BEGIN 
					INSERT INTO dbo.PropiedadXConceptoCobro (
						IdPropiedad,
						IdConceptoCobro,
						FechaInicio)
					SELECT P.Id,
						C.Id,
						@inDate
					FROM dbo.Propiedad AS P,
						dbo.ConceptoCobro AS C
					WHERE P.NumeroFinca = @inFincNum
						AND C.Nombre = 'MantenimientoParques';
				END;

				--Agrega el servicio: Patente comercial
				INSERT INTO dbo.PropiedadXConceptoCobro (
					IdPropiedad,
					IdConceptoCobro,
					FechaInicio)
				SELECT P.Id,
					C.Id,
					@inDate
				FROM dbo.Propiedad AS P,
					dbo.ConceptoCobro AS C
				WHERE P.NumeroFinca = @inFincNum
					AND C.Nombre = 'Patente comercial';

				--Agrega el servicio: Impuesto sobre propiedad
				INSERT INTO dbo.PropiedadXConceptoCobro (
					IdPropiedad,
					IdConceptoCobro,
					FechaInicio)
				SELECT P.Id,
					C.Id,
					@inDate
				FROM dbo.Propiedad AS P,
					dbo.ConceptoCobro AS C
				WHERE P.NumeroFinca = @inFincNum
					AND C.Nombre = 'Impuesto a propiedad';

				--Agrega el servicio: ConsumoAgua
				INSERT INTO dbo.PropiedadXConceptoCobro (
					IdPropiedad,
					IdConceptoCobro,
					FechaInicio)
				SELECT P.Id,
					C.Id,
					@inDate
				FROM dbo.Propiedad AS P,
					dbo.ConceptoCobro AS C
				WHERE P.NumeroFinca = @inFincNum
					AND C.Nombre = 'ConsumoAgua';

		COMMIT TRANSACTION tPropiedadXCC;
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION tPropiedadXCC;
		END
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

--Lee de la tabla Propiedades
CREATE PROCEDURE dbo.ReadProperty
AS
BEGIN
	SET NOCOUNT ON;

	SELECT P.Id, 
		P.NumeroFinca,
		TU.Nombre AS TipoUso, 
		TZ.Nombre AS TipoZona,
		P.Area,
		P.ValorFiscal,
		P.NumeroMedidor,
		CAST(P.FechaRegistro AS VARCHAR(16)) AS FechaRegistro,
		P.Activo
		FROM dbo.Propiedad AS P
		INNER JOIN dbo.TipoUsoPropiedad AS TU ON TU.Id = P.IdTipoUsoPropiedad
		INNER JOIN dbo.TipoZonaPropiedad AS TZ ON TZ.Id = P.IdTipoZonaPropiedad
		ORDER BY P.NumeroFinca;

	SET NOCOUNT OFF;
END;
GO

CREATE PROCEDURE dbo.SearchProperty
	@inNumFinca INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';

	--Revisa si el número de finca es nulo
	IF (@inNumFinca IS NULL OR @inNumFinca = 0)
	BEGIN
		SET @outResultCode = 50001;
		SET  @outResultMessage = 'Parámetros nulos';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	SELECT P.Id, 
		P.NumeroFinca,
		TU.Nombre AS TipoUso, 
		TZ.Nombre AS TipoZona,
		P.Area,
		P.ValorFiscal,
		P.NumeroMedidor,
		CAST(P.FechaRegistro AS VARCHAR(16)) AS FechaRegistro,
		P.Activo
		FROM dbo.Propiedad AS P
		INNER JOIN dbo.TipoUsoPropiedad AS TU ON TU.Id = P.IdTipoUsoPropiedad
		INNER JOIN dbo.TipoZonaPropiedad AS TZ ON TZ.Id = P.IdTipoZonaPropiedad
		WHERE P.NumeroFinca = @inNumFinca
		ORDER BY P.NumeroFinca;

	SET NOCOUNT OFF;
END;
GO

--Lee de TipoUsoPropiedad
CREATE PROCEDURE dbo.ReadUse
AS
BEGIN
	SET NOCOUNT ON;
	SELECT TU.Id,
		TU.Nombre
		FROM dbo.TipoUsoPropiedad AS TU;
	SET NOCOUNT OFF;
END;
GO

--Lee de TipoZonaPropiedad
CREATE PROCEDURE dbo.ReadZone
AS
BEGIN
	SET NOCOUNT ON;
	SELECT TZ.Id,
		TZ.Nombre
		FROM dbo.TipoZonaPropiedad AS TZ;
	SET NOCOUNT OFF;
END;
GO

--Busca una propiedad por su número de finca y actualiza los valores solicitados
CREATE PROCEDURE dbo.UpdateProperty
	@inNumFinc INT,
	@inNewUse VARCHAR(32),
	@inNewZone VARCHAR(32),
	@inNewArea INT,
	@inNewFiscalValue BIGINT,
	@inNewMedNum INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		--Revisa si el número de finca es nulo
		IF (@inNumFinc IS NULL OR @inNumFinc = 0)
		BEGIN
			SET @outResultCode = 50001;
			SET  @outResultMessage = 'Parámetros nulos';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Si no existe el número de finca
		IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE NumeroFinca = @inNumFinc)
		BEGIN
			SET @outResultCode = 50006;
			SET @outResultMessage = 'No existe la propiedad';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		--Reemplaza guiones por espacios para que coincida con los valores de la tabla TipoUsoPropiedad 
		SET @inNewUse = REPLACE(@inNewUse, N'-', N' ');
		--Reemplaza guiones por espacios para que coincida con los valores de la tabla TipoZonaPropiedad 
		SET @inNewZone = REPLACE(@inNewZone, N'-', N' ');

		--Actualiza el tipo de uso si se ingresó un nuevo valor
		IF (LEN(@inNewUse) > 0 AND @inNewUse IS NOT NULL)
		BEGIN
			UPDATE dbo.Propiedad
				SET IdTipoUsoPropiedad = TU.Id
				FROM dbo.TipoUsoPropiedad AS TU
				WHERE NumeroFinca = @inNumFinc
					 AND TU.Nombre = @inNewUse;
		END;

		--Actualiza el tipo de zona si se ingresó un nuevo valor
		IF (LEN(@inNewZone) > 0 AND @inNewZone IS NOT NULL)
		BEGIN
			UPDATE dbo.Propiedad
				SET IdTipoZonaPropiedad = TZ.Id
				FROM dbo.Propiedad AS P
				INNER JOIN dbo.TipoZonaPropiedad AS TZ ON TZ.Nombre = @inNewZone
				WHERE P.NumeroFinca = @inNumFinc;
		END;

		--Actualiza el tamaño de la finca si se ingresó un nuevo valor
		IF (@inNewArea IS NOT NULL AND @inNewArea > 0)
		BEGIN
			UPDATE dbo.Propiedad
				SET Area = @inNewArea
				WHERE NumeroFinca = @inNumFinc;
		END;

		--Actualiza el valor fiscal si se ingresó un nuevo valor
		IF (@inNewFiscalValue IS NOT NULL AND @inNewFiscalValue > 0)
		BEGIN
			UPDATE dbo.Propiedad
				SET ValorFiscal = @inNewFiscalValue
				WHERE NumeroFinca = @inNumFinc;
		END;

		--Actualiza el número de medidor si se ingresó un nuevo valor
		IF (@inNewMedNum IS NOT NULL AND @inNewMedNum > 0)
		BEGIN
			UPDATE dbo.Propiedad
				SET NumeroMedidor = @inNewMedNum
				WHERE NumeroFinca = @inNumFinc;
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

--Desactiva una propiedad, se selecciona por número de finca
CREATE PROCEDURE dbo.DeleteProperty
	@inNumFinc INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';
		
		IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE NumeroFinca = @inNumFinc)
		BEGIN
			SET @outResultCode = 50006;
			SET @outResultMessage = 'No existe la propiedad';
			SELECT @outResultCode AS ResultCode,
				@outResultMessage AS ResultMessage;
			RETURN;
		END;

		UPDATE dbo.Propiedad
			SET Activo = 0
			WHERE NumeroFinca = @inNumFinc;

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