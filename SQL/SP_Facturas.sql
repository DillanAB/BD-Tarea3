CREATE PROCEDURE dbo.GenerarFacturas
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';
	BEGIN TRY
		DECLARE @PropCCTemp TABLE(
			Sec INT IDENTITY (1,1),
			IdPropCC INT,
			IdPropiedad INT,
			IdCC INT,
			FechaRegistro DATE);

		DECLARE	@numDiaOp INT = DAY(@inDate), --Se saca cada parte de la fecha de operación
			@numMesOp INT = MONTH(@inDate),
			@numAñoOp INT = YEAR(@inDate),
			@numDiaVenci INT, --Para la fecha de vencimiento
			@numMesVenci INT,
			@numAñoVenci INT,
			@maxDia INT,	--Indica el último día del mes
			@indexFinal INT, --Cantidad total de iteraciones
			@propCCIndex INT, --Lleva el número de iteración actual
			@idPropCC INT,
			@idPropiedad INT,
			@idCC INT,
			@m3Acum INT,
			@m3AcumFactAnt INT,
			@valor FLOAT,
			@fechaRegistro DATE, --FechaRegistro de la propiedad
			@IDEVENTGENFACTURAS INT = 8,
			@idEventLogActual INT,
			@lastIdIndex INT;

		--Revisa si ha sido ejecutado en la fecha ingresada
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTGENFACTURAS) AND (E.EventDate = @inDate)
					AND E.LastIdProcessed = E.LastIdToBeProcessed)
		BEGIN
			SET @outResultCode=50020;
			SET @outResultMessage = 'Proceso ya ejecutado en la fecha';
			RETURN;
		END;
		
		SET @maxDia = 
			CASE
				WHEN @numMesOp IN (1,3,5,7,8,10,12) THEN 31 --Meses de 31 días
				WHEN @numMesOp IN (4,6,9,11) THEN 30 --Meses de 30 días 
				WHEN (((@numAñoOp % 4) = 0 AND (@numAñoOp % 100) <> 0) OR (@numAñoOp % 400) = 0)
					THEN 29 --Si el año es biciesto, febrero tiene 29 días
				ELSE 28 --Si el año no es biciesto, febrero tiene 28 días
			END;
		--Si se realiza en diciembre, la fecha de vencimiento cambia de año
		SET @numAñoVenci = 
			CASE
				WHEN @numMesOp = 12 THEN @numAñoOp + 1
				ELSE @numAñoOp
			END;
		--Evita que el mes de la fecha de vencimiento pase a 13
		SET @numMesVenci =
			CASE
				WHEN @numMesOp = 12 THEN 1
				ELSE @numMesOp + 1
			END;
		--Selecciona el día de la fecha de vencimiento
		SET @numDiaVenci = 
			CASE
				WHEN (@numMesVenci <> 2 AND @numDiaOp <= 30) THEN @numDiaOp --La fecha de vencimiento queda el mismo día
				WHEN (@numMesVenci IN (1,3,5,7,8,10,12) AND @numDiaOp = @maxDia) THEN 31 
				WHEN (@numMesVenci IN (4,6,9,11) AND @numDiaOp = @maxDia) THEN 30
				WHEN (@numMesVenci = 2 AND (((@numAñoOp % 4) = 0 AND (@numAñoOp % 100) <> 0) OR (@numAñoOp % 400) = 0))
					THEN 29 --Queda en 29 por ser febrero bisiesto
				ELSE 28 --Queda en 28 por ser febrero no bisiesto
			END;

		INSERT INTO @PropCCTemp (
			IdPropCC,
			IdPropiedad,
			IdCC,
			FechaRegistro)
		SELECT PC.Id,
			PC.IdPropiedad,
			PC.IdConceptoCobro,
			P.FechaRegistro
		FROM dbo.PropiedadXConceptoCobro AS PC
			INNER JOIN dbo.Propiedad AS P ON P.Id = PC.IdPropiedad
		WHERE DAY(P.FechaRegistro) = @numDiaOp --Propiedades con día de registro en el mismo día del mes
			OR (DAY(P.FechaRegistro) > @maxDia AND @maxDia = @numDiaOp); --O propiedades con día superior a la cantidad del mes
																		--cuando el día de operación es el último del mes
		SET @indexFinal = (SELECT MAX(Sec) FROM @PropCCTemp);

		--Revisa si se inició y no terminó
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTGENFACTURAS) AND (E.EventDate = @inDate))
		BEGIN
			SELECT @lastIdIndex = E.LastIdToBeProcessed    -- Hay que iniciar el proceso despues del ultimo
			, @idEventLogActual= E.Id
			FROM dbo.EventLogProcesosMasivos AS E
			WHERE (E.IdEventType=@IDEVENTGENFACTURAS) AND (E.EventDate = @inDate)
		
			SELECT @propCCIndex = P.Sec+1      -- la iteracion comienza despues del ultimo procesado
			FROM @PropCCTemp AS P 
			WHERE P.Sec  = @lastIdIndex
		END
		ELSE BEGIN
			Set @propCCIndex=1;

			INSERT dbo.EventLogProcesosMasivos (
				IdEventType, 
				EventDate, 
				Description,
				LastIdToBeProcessed,
				LastIdProcessed)
			VALUES (@IDEVENTGENFACTURAS,
				@inDate,
				'Proceso masivo facturas',
				@indexFinal,
				0);

			SET @IdEventLogActual=SCOPE_IDENTITY();
		END;

		WHILE @indexFinal > @propCCIndex
		BEGIN
			SELECT @idPropCC = PC.IdPropCC,
				@idPropiedad = PC.IdPropiedad,
				@idCC = PC.IdCC,
				@fechaRegistro = PC.FechaRegistro
			FROM @PropCCTemp AS PC
			WHERE PC.Sec = @propCCIndex;

			IF @idCC = 1 --Si es de ConsumoAgua
			BEGIN
				SELECT 
					@m3Acum = PC.SaldoAcumulado,
					@m3AcumFactAnt = PC.SaldoAcumuladoUltimaFactura,
					@valor =
						CASE 
							WHEN (PC.SaldoAcumulado-PC.SaldoAcumuladoUltimaFactura)*A.ValorM3>A.MontoMinimo
								THEN (PC.SaldoAcumulado - PC.SaldoAcumuladoUltimaFactura)*A.ValorM3
							ELSE A.MontoMinimo
						END
				FROM dbo.CCAgua AS A
					INNER JOIN dbo.PropiedadCCAgua AS PC ON PC.IdPropiedadXCC = @idPropCC
			END 
			
			IF @idCC = 2 --Si es de Impuesto a propiedad
			BEGIN
				SELECT @valor = (P.ValorFiscal * I.ValorPorcentual)/12
				FROM dbo.CCImpuestoPropiedad AS I,
					dbo.Propiedad P
				WHERE P.Id = @idPropiedad
			END 

			IF @idCC = 3 --Recoleccion Basura
			BEGIN
				SELECT @valor = 
				CASE
					WHEN P.Area <= R.ValorM2Minimo THEN R.ValorMinimo
					ELSE R.ValorMinimo + 75*((P.Area - R.ValorM2Minimo)/R.ValorTractosM2)
				END
				FROM dbo.CCRecoleccionBasura AS R,
					dbo.Propiedad P
				WHERE P.Id = @idPropiedad
			END 

			IF @idCC = 4 --Si es de Patente Comercial
			BEGIN
				SELECT @valor = C.ValorFijo/12
				FROM dbo.CCPatenteComercial AS C,
					dbo.Propiedad P
				WHERE P.Id = @idPropiedad
			END

			IF @idCC = 5 --Si es de Reconexion
			BEGIN
				SELECT @valor = R.ValorFijo
				FROM dbo.CCReconexion AS R,
					dbo.Propiedad P
				WHERE P.Id = @idPropiedad
			END 

			IF @idCC = 7 --Si es de MantenimientoParques
			BEGIN
				SELECT @valor = M.ValorFijo
				FROM dbo.CCMantenimientoParques AS M,
					dbo.Propiedad P
				WHERE P.Id = @idPropiedad
			END
			
			BEGIN TRANSACTION tFactProp
				--Si no existe una factura para la propiedad con fecha de la operación
				IF NOT EXISTS (SELECT 1 FROM dbo.Factura F WHERE F.IdPropiedad = @idPropiedad AND F.Fecha = @inDate)
				BEGIN
					INSERT INTO dbo.Factura (
						IdPropiedad,
						Fecha,
						FechaVencimiento,
						TotalOriginal,
						TotalPagar)
					SELECT @idPropiedad,
						CASE
							WHEN DAY(@fechaRegistro) > @maxDia THEN DATEFROMPARTS(@numAñoOp, @numMesOp, @maxDia) --Si el día de registro es mayor a los días del mes
							ELSE @inDate
						END,
						DATEFROMPARTS(@numAñoVenci, @numMesVenci, @numDiaVenci),
						@valor,
						@valor
					FROM @PropCCTemp AS P
					WHERE P.Sec = @propCCIndex
				END
				ELSE
				BEGIN
					UPDATE dbo.Factura 
					SET TotalOriginal = TotalOriginal + @valor,
						TotalPagar = TotalPagar + @valor
					WHERE IdPropiedad = @idPropiedad
						AND Fecha = @inDate
				END
				--Genera el detalle de cobro
				INSERT INTO dbo.DetalleCC (
					IdFactura,
					IdConceptoCobro,
					Monto)
				SELECT F.Id,
					@idCC,
					@valor
				FROM dbo.Factura AS F
				WHERE F.IdPropiedad = @idPropiedad
					AND F.Fecha = @inDate;
				
				--Si es CCAgua gnera el DetalleCCAgua
				IF @idCC = 1
				BEGIN 
					INSERT INTO dbo.DetalleCCAgua (
						IdDetalle,
						IdMovConsumo)
					SELECT D.Id,
						M.Id
					FROM dbo.DetalleCC AS D
						INNER JOIN dbo.MovimientoConsumo AS M ON M.IdPropiedadCCAgua = @idPropCC
					WHERE M.NuevoSaldo = @m3Acum;

					UPDATE dbo.PropiedadCCAgua
						SET SaldoAcumuladoUltimaFactura = @m3Acum
					WHERE IdPropiedadXCC = @idPropCC;
				END
				--Actualiza EventLog
				UPDATE dbo.EventLogProcesosMasivos 
				SET LastIdProcessed = @propCCIndex
				WHERE Id=@idEventLogActual;

			COMMIT TRANSACTION tFactProp
			SET @propCCIndex = @propCCIndex + 1
		END --Final WHILE

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0 BEGIN
			ROLLBACK TRANSACTION tFactProp;
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

CREATE PROCEDURE dbo.GenerarIntereses
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';
	BEGIN TRY
		DECLARE @FactTemp TABLE(
			Sec INT IDENTITY (1,1),
			IdFactura INT,
			MontoOriginal FLOAT);

		DECLARE	@numDiaOp INT = DAY(@inDate),
			@numMesOp INT = MONTH(@inDate),
			@numAñoOp INT = YEAR(@inDate),
			@maxDia INT,
			@IDCCINTERES INT,
			@TASAINTERES FLOAT,
			@finalIndex INT,
			@factIndex INT,
			@idFactura INT,
			@montoOriginal FLOAT,
			@montoInteres FLOAT,
			@IDEVENTINTERESES INT = 10,
			@lastIdIndex INT,
			@idEventLogActual INT;

		--Revisa si ha sido ejecutado en la fecha ingresada
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTINTERESES) AND (E.EventDate = @inDate)
					AND E.LastIdProcessed = E.LastIdToBeProcessed)
		BEGIN
			SET @outResultCode=50020;   
			SET @outResultMessage = 'Proceso ya ejecutado en la fecha';
			RETURN;
		END;

		SET @maxDia = 
			CASE
				WHEN @numMesOp IN (1,3,5,7,8,10,12) THEN 31 --Meses de 31 días
				WHEN @numMesOp IN (4,6,9,11) THEN 30 --Meses de 30 días 
				WHEN (((@numAñoOp % 4) = 0 AND (@numAñoOp % 100) <> 0) OR (@numAñoOp % 400) = 0)
					THEN 29 --Si el año es biciesto, febrero tiene 29 días
				ELSE 28 --Si el año no es biciesto, febrero tiene 28 días
			END;

		--Asigna el Id y el valor porcentual del CC intereses
		SELECT @IDCCINTERES = I.IdCC,
			@TASAINTERES = I.ValorPorcentual
		FROM dbo.CCInteresesMoratorios AS I;
		
		INSERT INTO @FactTemp (
			IdFactura,
			MontoOriginal)
		SELECT F.Id,
			F.TotalOriginal
		FROM dbo.Factura AS F
		WHERE F.IdEstado = 1 AND (
			DAY(F.FechaVencimiento) = @numDiaOp --Propiedades con día de registro en el mismo día del mes
			OR (DAY(F.FechaVencimiento) > @maxDia AND @maxDia = @numDiaOp)); --O propiedades con día superior a la cantidad del mes
																			--cuando el día de operación es el último del mes

		SET @finalIndex = (SELECT MAX(Sec) FROM @FactTemp);

		--Revisa si se inició y no terminó
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTINTERESES) AND (E.EventDate = @inDate))
		BEGIN
			SELECT @lastIdIndex = E.LastIdToBeProcessed    -- Hay que iniciar el proceso despues del ultimo
			, @idEventLogActual = E.Id
			FROM dbo.EventLogProcesosMasivos AS E
			WHERE (E.IdEventType = @IDEVENTINTERESES) AND (E.EventDate=@inDate);
		
			SELECT @factIndex = F.Sec+1      -- la iteracion comienza despues del ultimo procesado
			FROM @FactTemp AS F
			WHERE F.Sec = @lastIdIndex;
		END
		ELSE BEGIN
			SET @factIndex = 1;

			INSERT dbo.EventLogProcesosMasivos (
				IdEventType, 
				EventDate, 
				Description,
				LastIdToBeProcessed,
				LastIdProcessed)
			VALUES (@IDEVENTINTERESES,
				@inDate,
				'Proceso masivo intereses',
				@finalIndex,
				0);

			SET @IdEventLogActual=SCOPE_IDENTITY();
		END;
			
		WHILE @finalIndex > @factIndex
		BEGIN
			SELECT @idFactura = F.IdFactura,
				@montoOriginal = F.MontoOriginal,
				@montoInteres = (F.MontoOriginal * @TASAINTERES/12)
			FROM @FactTemp AS F
			WHERE F.Sec = @factIndex;

			BEGIN TRANSACTION tIntereses

				INSERT INTO dbo.DetalleCC (
					IdFactura,
					IdConceptoCobro,
					Monto)
				SELECT @idFactura,
					@idCCInteres,
					@montoInteres;

				UPDATE dbo.Factura 
				SET TotalPagar = TotalPagar + @montoInteres
				WHERE Id = @idFactura;

				UPDATE dbo.EventLogProcesosMasivos 
				SET LastIdProcessed = @factIndex
				WHERE Id=@IdEventLogActual;

			COMMIT TRANSACTION tIntereses

			SET @factIndex = @factIndex + 1;
		END --Final del WHILE
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0 BEGIN
			ROLLBACK TRANSACTION tIntereses;
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

CREATE PROCEDURE dbo.GenerarOrdenCorte
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';
	BEGIN TRY
		DECLARE @IDCCRECONEXION INT,
			@MONTO INT,
			@finalIndex INT,
			@ordenIndex INT,
			@idFactura INT,
			@idPropiedad INT,
			@IDEVENTORDENCORTE INT,
			@idEventLogActual INT,
			@lastIdIndex INT;

		--Revisa si ha sido ejecutado en la fecha ingresada
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTORDENCORTE) AND (E.EventDate = @inDate)
					AND E.LastIdProcessed=E.LastIdToBeProcessed)
		BEGIN
			SET @outResultCode=50020     
			SET @outResultMessage = 'Proceso ya ejecutado en la fecha';
			RETURN;
		END;
			
		SELECT @IDCCRECONEXION = R.IdCC,
			@MONTO = R.ValorFijo
		FROM dbo.CCReconexion AS R;
		
		DECLARE @OrdenTemp TABLE(
			Sec INT IDENTITY (1,1),
			IdFactura INT,
			IdPropiedad INT);

		INSERT INTO @OrdenTemp(
			IdFactura,
			IdPropiedad)
		SELECT F.Id,
			P.Id
		FROM dbo.Propiedad AS P
			INNER JOIN dbo.Factura AS F ON F.IdPropiedad = P.Id
		WHERE F.IdEstado = 1
			AND (EXISTS (SELECT 1 
					FROM dbo.PropiedadXConceptoCobro PC 
					WHERE PC.IdPropiedad = P.Id
						AND PC.IdConceptoCobro = 1
						AND PC.FechaFin = NULL)) --Que exista CCAgua en la propiedad que no haya terminado (FechaFin = NULL)
			AND NOT EXISTS (SELECT 1 
					FROM dbo.OrdenCorteAgua O 
					WHERE O.IdFactura = F.Id 
						AND O.Estado = 1) --Que no exista ya una orden de corte activa (Sin pagar)
			AND (F.Fecha = (SELECT MIN(F2.Fecha) 
					FROM dbo.Factura F2 
					WHERE F2.IdPropiedad = P.Id
						AND F2.IdEstado = 1)) --Que la factura seleccionada por propiedad sea la más antigua sin pagar
			AND (1 < (SELECT COUNT(1) 
					FROM dbo.Factura F3 
					WHERE F3.IdEstado = 1
						AND F3.IdPropiedad = P.Id)); --Que haya más de una factura pendiente asociada a la propiedad

		SET @finalIndex = (SELECT MAX(Sec) FROM @OrdenTemp);

		--Revisa si se inició y no terminó
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTORDENCORTE) AND (E.EventDate = @inDate))
		BEGIN
			SELECT @lastIdIndex = E.LastIdToBeProcessed    -- Hay que iniciar el proceso despues del ultimo
			, @idEventLogActual = E.Id
			FROM dbo.EventLogProcesosMasivos AS E
			WHERE (E.IdEventType = @IDEVENTORDENCORTE) AND (E.EventDate=@inDate);
		
			SELECT @ordenIndex = O.Sec + 1      -- la iteracion comienza despues del ultimo procesado
			FROM @OrdenTemp AS O
			WHERE O.Sec = @lastIdIndex;
		END
		ELSE BEGIN
			Set @ordenIndex = 1;

			INSERT dbo.EventLogProcesosMasivos (
				IdEventType, 
				EventDate, 
				Description,
				LastIdToBeProcessed,
				LastIdProcessed)
			VALUES (@IDEVENTORDENCORTE,
				@inDate,
				'Proceso masivo ordenes corte',
				@finalIndex,
				0);

			SET @IdEventLogActual=SCOPE_IDENTITY();
		END;

		WHILE @finalIndex > @ordenIndex
		BEGIN 
			SELECT @idFactura = O.IdFactura,
				@idPropiedad = O.IdPropiedad
			FROM @OrdenTemp AS O
			WHERE O.Sec = @ordenIndex;

			BEGIN TRANSACTION tOrdenes
					INSERT INTO dbo.OrdenCorteAgua (
						IdFactura,
						FechaCorte)
					SELECT  @idFactura,
						@inDate;
						
					INSERT INTO dbo.DetalleCC (
						IdFactura,
						IdConceptoCobro,
						Monto)
					SELECT @idFactura,
						@idCCReconexion,
						@monto;

					UPDATE dbo.Factura
					SET TotalPagar = TotalPagar + @monto
					WHERE Id = @idFactura;

					UPDATE dbo.EventLogProcesosMasivos 
					SET LastIdProcessed = @ordenIndex
					WHERE Id=@IdEventLogActual;

				COMMIT TRANSACTION tOrdenes
			SET @ordenIndex = @ordenIndex + 1;
		END; --Fin del WHILE
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0 BEGIN
			ROLLBACK TRANSACTION tOrdenes;
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
		SET @outResultMessage = 'Fallo del sistema';
	END CATCH
	SET NOCOUNT OFF;
END
GO

CREATE PROCEDURE dbo.GenerarReconexiones
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';
	BEGIN TRY
		DECLARE @IDEVENTRECON INT = 7;

		--Revisa si ha sido ejecutado en la fecha ingresada
		IF EXISTS (SELECT 1 FROM dbo.EventLogProcesosMasivos E WHERE (E.IdEventType = @IDEVENTRECON) AND (E.EventDate = @inDate))
		BEGIN
			SET @outResultCode = 50020     
			SET @outResultMessage = 'Proceso ya ejecutado en la fecha';
			RETURN;
		END;

		BEGIN TRANSACTION tReconexiones;
			INSERT INTO dbo.OrdenReconexion (
				IdOrdenCorte,
				FechaReconexion)
			SELECT OC.Id,
				@inDate
			FROM dbo.OrdenCorteAgua AS OC
			WHERE OC.Estado = 2	--Que la orden de corte ya haya sido pagada
				AND NOT EXISTS (SELECT 1 
						FROM dbo.OrdenReconexion AS OR2 
						WHERE OR2.IdOrdenCorte = OC.Id) --Que la Id de orden de corte no exista en ordenReconexion

			INSERT dbo.EventLogProcesosMasivos (
				IdEventType, 
				EventDate, 
				Description)
			VALUES (@IDEVENTRECON,
				@inDate,
				'Proceso masivo reconexiones');

		COMMIT TRANSACTION tReconexiones;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0 BEGIN
			ROLLBACK TRANSACTION tReconexiones;
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