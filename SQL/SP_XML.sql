USE [Servicios];
GO

CREATE TYPE dbo.TProp AS TABLE (
	Id INT IDENTITY (1,1) NOT NULL,
	SEC INT NOT NULL,
	TipoUsoPropiedad VARCHAR(32) NOT NULL,
	TipoZonaPropiedad VARCHAR(32) NOT NULL,
	NumeroFinca INT NOT NULL,
	Area INT NOT NULL,
	ValorFiscal BIGINT NOT NULL,
	NumeroMedidor INT NOT NULL,
	PRIMARY KEY CLUSTERED (Id ASC));
GO

CREATE TYPE dbo.TAsoPP AS TABLE (
	Id INT IDENTITY (1,1) NOT NULL,
	SEC INT NOT NULL,
	ValDocPersona INT NOT NULL,
	NumFinca INT NOT NULL,
	TipoAsociacion VARCHAR(16) NOT NULL
	PRIMARY KEY CLUSTERED (Id ASC))
GO

CREATE TYPE dbo.TUser AS TABLE (
	Id INT IDENTITY (1,1) NOT NULL,
	SEC INT NOT NULL,
	ValDocPersona INT NOT NULL,
	Username VARCHAR(32) NOT NULL,
	Password VARCHAR(32) NOT NULL,
	TipoUsuario VARCHAR(16) NOT NULL,
	TipoAsociacion VARCHAR(16) NOT NULL
	PRIMARY KEY CLUSTERED (Id ASC));
GO

CREATE TYPE dbo.TAsoUP AS TABLE (
	Id INT IDENTITY (1,1) NOT NULL,
	SEC INT NOT NULL,
	ValDocPersona INT NOT NULL,
	NumFinca INT NOT NULL,
	TipoAsociacion VARCHAR(16) NOT NULL
	PRIMARY KEY CLUSTERED (Id ASC));
GO

CREATE TYPE dbo.TLectura AS TABLE (
	Id INT IDENTITY (1,1) NOT NULL,
	SEC INT NOT NULL,
	NumeroMedidor INT NOT NULL,
	TipoMovimiento VARCHAR(32) NOT NULL,
	Valor INT NOT NULL
	PRIMARY KEY CLUSTERED (Id ASC));
GO

CREATE TYPE dbo.TPago AS TABLE (
	Id INT IDENTITY (1,1) NOT NULL,
	SEC INT NOT NULL,
	NumeroFinca INT NOT NULL,
	TipoPago VARCHAR(64) NOT NULL,
	NumeroReferencia INT NOT NULL
	PRIMARY KEY CLUSTERED (Id ASC));
GO

CREATE TYPE dbo.TCambioValor AS TABLE (
	Id INT IDENTITY (1,1) NOT NULL,
	SEC INT NOT NULL,
	NumeroFinca INT NOT NULL,
	NuevoValor BIGINT NOT NULL,
	PRIMARY KEY CLUSTERED (Id ASC));
GO

CREATE PROCEDURE dbo.PropiedadXML
	@InTablaProp dbo.TProp READONLY,
	@inPropIndex INT,
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		DECLARE @NumFinca INT = (SELECT NumeroFinca FROM @InTablaProp WHERE SEC = @inPropIndex );
		--Se prueba que el número de finca no exista ya en la tabla Propiedad
		IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad P WHERE P.NumeroFinca = @NumFinca )
		BEGIN
			DECLARE @TipoUso VARCHAR(32) = (SELECT TipoUsoPropiedad FROM @InTablaProp WHERE SEC = @inPropIndex);
			DECLARE @TipoZona VARCHAR(32) = (SELECT TipoZonaPropiedad FROM @InTablaProp WHERE SEC = @inPropIndex);
			BEGIN TRANSACTION tPropiedadXCCXML
				--Si el número de finca no se repite se procede a insertar en la tabla Propiedad
				INSERT INTO dbo.Propiedad(
					IdTipoUsoPropiedad,
					IdTipoZonaPropiedad,
					NumeroFinca,
					Area,
					ValorFiscal,
					NumeroMedidor,
					FechaRegistro)
				SELECT TU.Id,
					TZ.Id,
					P.NumeroFinca,
					P.Area,
					P.ValorFiscal,
					P.NumeroMedidor,
					@inDate
				FROM @InTablaProp AS P
					INNER JOIN dbo.TipoUsoPropiedad AS TU ON TU.Nombre = P.TipoUsoPropiedad --Obtiene el tipo que le corresponde
					INNER JOIN dbo.TipoZonaPropiedad AS TZ ON TZ.Nombre = P.TipoZonaPropiedad
				WHERE P.SEC = @inPropIndex;

				--Si no es de uso agrícola se agrega el servicio: Recoleccion Basura
				IF ( @TipoUso <> 'Agricola')
				BEGIN 
					INSERT INTO dbo.PropiedadXConceptoCobro (
						IdPropiedad,
						IdConceptoCobro,
						FechaInicio)
					SELECT P.Id,
						CC.Id,
						@inDate
					FROM dbo.Propiedad AS P,
						dbo.ConceptoCobro AS CC
					WHERE P.NumeroFinca = @NumFinca
						AND CC.Nombre = 'Recoleccion Basura';
				END;

				--Si es de área comercial o residencial se agrega el servicio: MantenimientoParques
				IF ( @TipoZona = 'Residencial'
					OR @TipoZona = 'Zona comercial')
				BEGIN 
					INSERT INTO dbo.PropiedadXConceptoCobro (
						IdPropiedad,
						IdConceptoCobro,
						FechaInicio)
					SELECT P.Id,
						CC.Id,
						@inDate
					FROM dbo.Propiedad AS P,
						dbo.ConceptoCobro AS CC
					WHERE P.NumeroFinca = @NumFinca
						AND CC.Nombre = 'MantenimientoParques';
				END;
				
				--Agrega el servicio: Patente comercial
				INSERT INTO dbo.PropiedadXConceptoCobro (
					IdPropiedad,
					IdConceptoCobro,
					FechaInicio)
				SELECT P.Id,
					CC.Id,
					@inDate
				FROM dbo.Propiedad AS P,
					dbo.ConceptoCobro AS CC
				WHERE P.NumeroFinca = @NumFinca
					AND CC.Nombre = 'Patente comercial';

				--Agrega el servicio: Impuesto a propiedad
				INSERT INTO dbo.PropiedadXConceptoCobro (
					IdPropiedad,
					IdConceptoCobro,
					FechaInicio)
				SELECT P.Id,
					CC.Id,
					@inDate
				FROM dbo.Propiedad AS P,
					dbo.ConceptoCobro AS CC
				WHERE P.NumeroFinca = @NumFinca
					AND CC.Nombre = 'Impuesto a propiedad';

				--Agrega el servicio: ConsumoAgua
				INSERT INTO dbo.PropiedadXConceptoCobro (
					IdPropiedad,
					IdConceptoCobro,
					FechaInicio)
				SELECT P.Id,
					CC.Id,
					@inDate
				FROM dbo.Propiedad AS P,
					dbo.ConceptoCobro AS CC
				WHERE P.NumeroFinca = @NumFinca
					AND CC.Nombre = 'ConsumoAgua';
				
				--Inserta en PropiedadCCAgua
				INSERT INTO dbo.PropiedadCCAgua (
					IdPropiedadXCC,
					NumeroMedidor,
					SaldoAcumulado)
				SELECT PC.Id,
					P.NumeroMedidor,
					0
				FROM dbo.PropiedadXConceptoCobro AS PC
					INNER JOIN dbo.Propiedad AS P ON P.Id = PC.IdPropiedad
				WHERE P.NumeroFinca = @NumFinca
					AND PC.IdConceptoCobro = 1;

			COMMIT TRANSACTION tPropiedadXCCXML
		END; --Fin del IF para insertar sólo si el número de finca no está repetido
		ELSE
		BEGIN
			SET @outResultCode = 50005;
			SET @outResultMessage = 'Ya existe una propiedad con el número de finca';
		END;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION tPropiedadXCCXML;
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
	END CATCH;
	SET NOCOUNT OFF;
END;
GO

CREATE PROCEDURE dbo.AsoPPXML
	@InTablaAsoPP dbo.TAsoPP READONLY,
	@inAsoPPIndex INT,
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';

		DECLARE @ValDocPersona INT = (SELECT ValDocPersona FROM @InTablaAsoPP WHERE SEC = @inAsoPPIndex);
		DECLARE @NumFinca INT = (SELECT NumFinca FROM @InTablaAsoPP WHERE SEC = @inAsoPPIndex);
		DECLARE @TipoAsociacion VARCHAR(16) = (SELECT TipoAsociacion FROM @InTablaAsoPP WHERE SEC = @inAsoPPIndex);
		--Si TipoAsociación es 1 (Agregar) inserta en la tabla PersonaXPropiedad
		IF (@TipoAsociacion = 'Agregar')
		BEGIN
			--Si existe una relación la persona con la identificación ingresada y una propiedad con el número de finca.
			IF ((EXISTS (SELECT 1 FROM dbo.Persona WHERE ValorDocumentoIdentidad = @ValDocPersona))
				AND (EXISTS (SELECT 1 FROM dbo.Propiedad WHERE NumeroFinca = @NumFinca)))
			BEGIN 
				INSERT INTO dbo.PersonaXPropiedad (
					IdPersona,
					IdPropiedad,
					FechaInicio)
				SELECT PE.Id,
					PR.Id,
					@inDate
				FROM dbo.Persona AS PE,
					dbo.Propiedad AS PR
				WHERE PE.ValorDocumentoIdentidad = @ValDocPersona
					AND PR.NumeroFinca = @NumFinca;
			END;
		END;
		--Si TipoAsociación es 2 (Eliminar) actualiza la FechaFin de la asociación
		ELSE
		BEGIN
			--Si existe una relación sin fechaFin entre la persona y la propiedad actualiza la FechaFin
			IF EXISTS (SELECT 1 
						FROM dbo.PersonaXPropiedad AS PP
						INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
						INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad
						WHERE PE.ValorDocumentoIdentidad = @ValDocPersona
							AND PR.NumeroFinca = @NumFinca
							AND PP.FechaFin IS NULL)
			BEGIN
				UPDATE dbo.PersonaXPropiedad
				SET FechaFin = @inDate	
				FROM dbo.PersonaXPropiedad AS PP
					INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
					INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad
				WHERE PE.ValorDocumentoIdentidad = @ValDocPersona
					AND PR.NumeroFinca = @NumFinca;
			END;
			ELSE
			BEGIN
				SET @outResultCode = 50011;
				SET  @outResultMessage = 'No existe una relación activa entre la persona y la propiedad';
			END;
		END;
		
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
	END CATCH
	SET NOCOUNT OFF;
END;
GO

CREATE PROCEDURE dbo.UserXML
	@InTablaUser dbo.TUser READONLY,
	@inUserIndex INT,
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SET @outResultCode = 0;
		SET @outResultMessage = 'Operación exitosa';
		DECLARE @TipoUsuario INT;

		--Asigna el valor númerico al tipo de ususario: 1=Administrador, 2=Propietario
		IF ((SELECT TipoUsuario FROM @InTablaUser WHERE SEC = @inUserIndex ) = 'Administrador')
		BEGIN 
			SET @TipoUsuario = 1;
		END;
		ELSE
		BEGIN 
			SET @TipoUsuario = 2;
		END;

		DECLARE @ValDocPersona INT = (SELECT ValDocPersona FROM @InTablaUser WHERE SEC = @inUserIndex);
		DECLARE @TipoAsociacion VARCHAR(16) = (SELECT TipoAsociacion FROM @InTablaUser WHERE SEC = @inUserIndex );
		--Si Tipo asociacion = Agregar se intenta insertar el usuario
		IF (@TipoAsociacion = 'Agregar')
		BEGIN
			--Revisa que exista la persona con la identificación
			IF EXISTS (SELECT 1 FROM dbo.Persona WHERE ValorDocumentoIdentidad = @ValDocPersona)
			BEGIN
				INSERT INTO dbo.Usuario (
					IdPersona,
					Username,
					Password,
					TipoUsuario)
				SELECT P.ID,
					U.Username,
					U.Password,
					@TipoUsuario
				FROM @InTablaUser AS U
					INNER JOIN dbo.Persona AS P ON P.ValorDocumentoIdentidad = @ValDocPersona
				WHERE U.SEC = @inUserIndex;
			END;
			--Si no existe la persona con la identificación ingresada
			ELSE
			BEGIN
				SET @outResultCode = 50008;
				SET  @outResultMessage = 'No existe la persona';
			END;
		END;
		--Si TipoAsociación = 2 entonces busca desactivar (Colocar Activo en 0) el usuario 
		ELSE
		BEGIN 
			--Se revisa que exista el usuario que se va a desactivar
			IF EXISTS (SELECT 1 
					FROM dbo.Usuario
					INNER JOIN dbo.Persona AS P ON P.ValorDocumentoIdentidad = @ValDocPersona)
			BEGIN 
				UPDATE dbo.Usuario
				SET Activo = 0
				FROM dbo.Usuario AS U
					INNER JOIN dbo.Persona AS P ON P.Id = U.IdPersona
				WHERE P.ValorDocumentoIdentidad = @ValDocPersona;
			END;
			ELSE
			BEGIN
				SET @outResultCode = 50004;
				SET  @outResultMessage = 'No existe el usuario';
			END;
		END; 
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
	END CATCH
	SET NOCOUNT OFF;
END;
GO

CREATE PROCEDURE dbo.AsoUPXML
	@InTablaAsoUP dbo.TAsoUP READONLY,
	@inAsoUPIndex INT,
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @ValDocPersona INT = (SELECT ValDocPersona FROM @InTablaAsoUP WHERE SEC = @inAsoUPIndex);
		DECLARE @NumFinca INT = (SELECT NumFinca FROM @InTablaAsoUP WHERE SEC = @inAsoUPIndex);
		DECLARE @TipoAsociacion VARCHAR(16) = (SELECT TipoAsociacion FROM @InTablaAsoUP WHERE SEC = @inAsoUPIndex);
	
		--Si TipoAsociación es 1 (Agregar) inserta en la tabla UsuarioXPropiedad
		IF (@TipoAsociacion = 'Agregar')
		BEGIN
			--Revisa que exista un usuario asociado a una persona con la identificación buscada y una propiedad con el número de finca
			IF ((EXISTS (SELECT 1 FROM dbo.Usuario U INNER JOIN dbo.Persona P ON P.Id = U.IdPersona WHERE P.ValorDocumentoIdentidad = @ValDocPersona))
				AND (EXISTS (SELECT 1 FROM dbo.Propiedad WHERE NumeroFinca = @NumFinca)))
			BEGIN 
				INSERT INTO dbo.UsuarioXPropiedad(
					IdUsuario,
					IdPropiedad,
					FechaInicio)
				SELECT U.Id,
					PR.Id,
					@inDate
				FROM dbo.Persona AS PE
					INNER JOIN dbo.Usuario AS U ON U.IdPersona = PE.Id
					INNER JOIN dbo.Propiedad AS PR ON PR.NumeroFinca = @NumFinca
				WHERE PE.ValorDocumentoIdentidad = @ValDocPersona;
			END;
			ELSE
			--Si no existe el usuario, asigna el error
			BEGIN
				SET @outResultCode = 50004;
				SET @outResultMessage = 'No existe el usuario';
			END;
		END;
		--Si TipoAsociación es 2 (Eliminar) actualiza la FechaFin de la asociación
		ELSE
		BEGIN
			--Busca si existe una relación sin FechaFin entre el usuario y la propiedad
			IF EXISTS (SELECT 1 
						FROM dbo.UsuarioXPropiedad AS UP
						INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
						INNER JOIN dbo.Persona AS PE ON PE.Id = U.IdPersona
						INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad
						WHERE PE.ValorDocumentoIdentidad = @ValDocPersona
						AND PR.NumeroFinca = @NumFinca
						AND UP.FechaFin IS NULL)
			BEGIN
				--Existe una asociación y se actualiza la FechaFin
				UPDATE dbo.UsuarioXPropiedad
				SET FechaFin = @inDate
				FROM dbo.UsuarioXPropiedad AS UP
					INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
					INNER JOIN dbo.Persona AS PE ON PE.Id = U.IdPersona
					INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad
				WHERE PE.ValorDocumentoIdentidad = @ValDocPersona
					AND PR.NumeroFinca = @NumFinca;
			END;
			ELSE
			--Si no existe relación, asigna el error
			BEGIN
				SET @outResultCode = 50013;
				SET @outResultMessage = 'No existe una relación activa entre el usuario y la propiedad';
			END;
		END;
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
	END CATCH
	SET NOCOUNT OFF;
END;
GO

CREATE PROCEDURE dbo.LecturasXML
	@InTablaLectura dbo.TLectura READONLY,
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';
	BEGIN TRY
		DECLARE @MovTemp TABLE (
			Id INT PRIMARY KEY IDENTITY,
			NumeroMedidor INT,
			IdTipoMov INT,
			Valor INT,
			IdPropiedad INT,
			SaldoAnterior INT);

		DECLARE @IDEVENTLECTURAS INT = 6;

		--Revisa si ha sido ejecutado en la fecha ingresada
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTLECTURAS) AND (E.EventDate = @inDate))
		BEGIN
			SET @outResultCode=50020     
			SET @outResultMessage = 'Proceso ya ejecutado en la fecha';
			RETURN;
		END;

		INSERT @MovTemp(
			NumeroMedidor,
			IdTipoMov,
			Valor,
			IdPropiedad,
			SaldoAnterior)
		SELECT L.NumeroMedidor,
			CASE
				WHEN L.TipoMovimiento = 'Lectura' THEN 1
				WHEN L.TipoMovimiento = 'Ajuste Credito' THEN 2
				WHEN L.TipoMovimiento = 'Ajuste Debito' THEN 3
			END,
			CASE
				WHEN L.TipoMovimiento = 'Lectura' THEN L.Valor - A.SaldoAcumulado
				WHEN L.TipoMovimiento = 'Ajuste Credito' THEN L.Valor
				WHEN L.TipoMovimiento = 'Ajuste Debito' THEN L.Valor*-1
			END,
			P.Id,
			A.SaldoAcumulado
		FROM @InTablaLectura AS L
		INNER JOIN dbo.PropiedadCCAgua AS A ON A.NumeroMedidor = L.NumeroMedidor
		INNER JOIN dbo.PropiedadXConceptoCobro AS PC ON PC.Id = A.IdPropiedadXCC
		INNER JOIN dbo.Propiedad AS P ON P.NumeroMedidor = L.NumeroMedidor;
		BEGIN TRANSACTION tLectura

			INSERT INTO dbo.MovimientoConsumo(
				IdPropiedadCCAgua,
				IdTipoMovConsumo,
				Monto,
				NuevoSaldo)
			SELECT PC.Id,
				M.IdTipoMov,
				M.Valor,
				M.SaldoAnterior+M.Valor
			FROM @MovTemp AS M
				INNER JOIN dbo.PropiedadXConceptoCobro AS PC ON PC.IdPropiedad = M.IdPropiedad
			WHERE PC.IdConceptoCobro = 1;

			UPDATE dbo.PropiedadCCAgua
			SET SaldoAcumulado = M.SaldoAnterior+M.Valor
			FROM dbo.PropiedadCCAgua AS A
			INNER JOIN @MovTemp AS M ON M.NumeroMedidor = A.NumeroMedidor;

			INSERT dbo.EventLogProcesosMasivos (
				IdEventType, 
				EventDate, 
				Description)
			VALUES (@IDEVENTLECTURAS,
				@inDate,
				'Proceso masivo lecturas');

		COMMIT TRANSACTION tLectura
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0 BEGIN
			ROLLBACK TRANSACTION tLectura;
		END;
		INSERT dbErrors		
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
		SET @outResultMessage = 'Fallo del sistema'
	END CATCH
	SET NOCOUNT OFF;
END
GO

CREATE PROCEDURE dbo.PagosXML
	@InTablaPagos dbo.TPago READONLY,
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';
	BEGIN TRY
		DECLARE @PagoTemp TABLE (
			Sec INT PRIMARY KEY IDENTITY,
			NumeroFinca INT,
			IdFactura INT,
			IdTipoPago INT,
			NumeroReferencia INT,
			MontoPago FLOAT,
			NuevoEstadoFactura INT);

		DECLARE @finalIndex INT,
			@pagoIndex INT,
			@numFinca INT,
			@idFactura INT,
			@idTipoPago INT,
			@numReferencia INT,
			@montoPago FLOAT,
			@nuevoEstadoFact INT,
			@IDEVENTPAGOS INT = 7,
			@IdEventLogActual INT,
			@LastIdIndex INT;

		--Revisa si ha sido ejecutado en la fecha ingresada
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTPAGOS) AND (E.EventDate = @inDate)
					AND E.LastIdProcessed = E.LastIdToBeProcessed)
		BEGIN
			SET @outResultCode = 50020     
			SET @outResultMessage = 'Proceso ya ejecutado en la fecha';
			RETURN;
		END;

		INSERT INTO @PagoTemp (
			NumeroFinca,
			IdFactura,
			IdTipoPago,
			NumeroReferencia,
			MontoPago,
			NuevoEstadoFactura)
		SELECT TP.NumeroFinca,
			F.Id,
			CASE
				WHEN TP.TipoPago = 'Efectivo' THEN 1
				WHEN TP.TipoPago = 'Tarjeta de débito o crédito' THEN 2
				WHEN TP.TipoPago = 'Transferencia bancaria' THEN 3
				WHEN TP.TipoPago = 'Arreglo de Pago' THEN 4
			END,
			TP.NumeroReferencia,
			F.TotalPagar,
			CASE
				WHEN TP.TipoPago = 'Arreglo de Pago' THEN 3 --Pagado por arreglo de pago
				ELSE 2 --Pagado normal
			END
		FROM @InTablaPagos AS TP
			INNER JOIN dbo.Propiedad AS P ON P.NumeroFinca = TP.NumeroFinca
			INNER JOIN dbo.Factura AS F ON F.IdPropiedad = P.Id
		WHERE F.IdEstado = 1 --Que la factura seleccionada siga sin pagarse
			AND (F.Fecha = (SELECT MIN(F2.Fecha) 
					FROM dbo.Factura F2 
					WHERE F2.IdPropiedad = P.Id
						AND F2.IdEstado = 1)); --Que la factura seleccionada por propiedad sea la más antigua sin pagar;

		SET @finalIndex = (SELECT MAX(P.Sec) FROM @PagoTemp P);

		--Revisa si se inició y no terminó
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType=@IDEVENTPAGOS) AND (E.EventDate=@inDate))
		BEGIN
			SELECT @LastIdIndex=E.LastIdToBeProcessed    -- Hay que iniciar el proceso despues del ultimo
			, @IdEventLogActual= E.Id
			FROM dbo.EventLogProcesosMasivos AS E
			WHERE (E.IdEventType=@IDEVENTPAGOS) AND (E.EventDate=@inDate);
		
			SELECT @pagoIndex=P.Sec+1      -- la iteracion comienza despues del ultimo procesado
			FROM @PagoTemp AS P 
			WHERE P.Sec=@LastIdIndex;
		END
		ELSE BEGIN
			SET @pagoIndex=1;

			INSERT dbo.EventLogProcesosMasivos (
				IdEventType, 
				EventDate, 
				Description,
				LastIdToBeProcessed,
				LastIdProcessed)
			VALUES (@IDEVENTPAGOS,
				@inDate,
				'Proceso masivo pagos',
				@finalIndex,
				0);

			SET @IdEventLogActual=SCOPE_IDENTITY();
		END;

		WHILE @finalIndex > @pagoIndex
		BEGIN
			SELECT @numFinca = P.NumeroFinca,
				@idFactura = P.IdFactura,
				@idTipoPago = P.IdTipoPago,
				@numReferencia = P.NumeroReferencia,
				@montoPago = P.MontoPago,
				@nuevoEstadoFact = P.NuevoEstadoFactura
			FROM @PagoTemp AS P
			WHERE P.Sec = @pagoIndex;

			BEGIN TRANSACTION tPago;
				--Genera el comprobante de pago
				INSERT INTO dbo.ComprobantePago (
					IdTipoPago,
					IdFactura,
					NumeroReferencia,
					MontoPago,
					Fecha)
				SELECT @idTipoPago,
					@idFactura,
					@numReferencia,
					@montoPago,
					@inDate;

				--Actualiza el estado de factura
				UPDATE dbo.Factura
				SET IdEstado = @nuevoEstadoFact
				WHERE Id = @idFactura;

				--Si la factura generó una orden de corte, actualiza su estado y genera la orden de reconexión
				IF EXISTS (SELECT 1 FROM dbo.OrdenCorteAgua O WHERE O.IdFactura = @idFactura)
				BEGIN
					--Actualiza el estado de orden de corte
					UPDATE dbo.OrdenCorteAgua
					SET Estado = 2,
						IdComprobantePago = C.Id
					FROM dbo.ComprobantePago AS C
					WHERE C.NumeroReferencia = @numReferencia;
					
					--Generera la orden de reconexión
					INSERT INTO dbo.OrdenReconexion (
						IdOrdenCorte,
						FechaReconexion)
					SELECT OC.Id,
						@inDate
					FROM dbo.OrdenCorteAgua AS OC
					WHERE OC.IdFactura = @idFactura;
				END;

				UPDATE dbo.EventLogProcesosMasivos 
				SET LastIdProcessed = @pagoIndex
				WHERE Id=@IdEventLogActual;

			COMMIT TRANSACTION tPago;
			SET @pagoIndex = @pagoIndex + 1;
		END --Fin del WHILE
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0 BEGIN
			ROLLBACK TRANSACTION tPago;
		END;
		INSERT dbErrors		
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
		SET @outResultMessage = 'Fallo del sistema'
	END CATCH
	SET NOCOUNT OFF;
END
GO

CREATE PROCEDURE dbo.CambiarValorXML
	@InTablaCambios dbo.TCambioValor READONLY,
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';
	BEGIN TRY
		DECLARE @finalIndex INT,
			@indexCambio INT,
			@numFinca INT,
			@nuevoVal BIGINT,
			@IDEVENTCAMBIOS INT = 11,
			@IdEventLogActual INT,
			@LastIdIndex INT;

		--Revisa si ha sido ejecutado en la fecha ingresada
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTCAMBIOS) AND (E.EventDate = @inDate)
					AND E.LastIdProcessed=E.LastIdToBeProcessed)
		BEGIN
			SET @outResultCode=50020     
			SET @outResultMessage = 'Proceso ya ejecutado en la fecha';
			RETURN;
		END;

		SET @finalIndex = (SELECT MAX(TC.Sec) FROM @InTablaCambios TC);

		--Revisa si se inició y no terminó
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTCAMBIOS) AND (E.EventDate=@inDate))
		BEGIN
			SELECT @LastIdIndex = E.LastIdToBeProcessed    -- Hay que iniciar el proceso despues del ultimo
			, @IdEventLogActual = E.Id
			FROM dbo.EventLogProcesosMasivos AS E
			WHERE (E.IdEventType = @IDEVENTCAMBIOS) AND (E.EventDate=@inDate);
		
			SELECT @indexCambio = TC.Sec+1      
			FROM @InTablaCambios AS TC 
			WHERE TC.Sec = @LastIdIndex;
		END;
		ELSE BEGIN
			SET @indexCambio = 1;

			INSERT dbo.EventLogProcesosMasivos (
				IdEventType, 
				EventDate, 
				Description,
				LastIdToBeProcessed,
				LastIdProcessed)
			VALUES (@IDEVENTCAMBIOS,
				@inDate,
				'Proceso masivo cambiar valor',
				@finalIndex,
				0);

			SET @IdEventLogActual=SCOPE_IDENTITY();
		END;

		WHILE @finalIndex > @indexCambio
		BEGIN
			SELECT @numFinca = TC.NumeroFinca,
				@nuevoVal = TC.NuevoValor
			FROM @InTablaCambios AS TC
			WHERE TC.SEC = @indexCambio;

			BEGIN TRANSACTION tCambios;

				UPDATE dbo.Propiedad
				SET ValorFiscal = @nuevoVal
				WHERE NumeroFinca = @numFinca;

				UPDATE dbo.EventLogProcesosMasivos 
				SET LastIdProcessed = @indexCambio
				WHERE Id=@IdEventLogActual;

			COMMIT TRANSACTION tCambios;
		END;

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0 BEGIN
			ROLLBACK TRANSACTION tCambios;
		END;
		INSERT dbErrors		
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
		SET @outResultMessage = 'Fallo del sistema'
	END CATCH
	SET NOCOUNT OFF;
END
GO