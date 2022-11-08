CREATE PROCEDURE dbo.GenerarFacturas
	@inDate DATE,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operaci�n exitosa';
	BEGIN TRY
		DECLARE @PropCCTemp TABLE(
			Sec INT IDENTITY (1,1),
			IdPropCC INT,
			IdPropiedad INT,
			IdCC INT,
			FechaRegistro DATE);

		DECLARE	@numDiaOp INT = DAY(@inDate),
			@numMesOp INT = MONTH(@inDate),
			@numA�oOp INT = YEAR(@inDate),
			@numDiaVenci INT, --Para la fecha de vencimiento
			@numMesVenci INT,
			@numA�oVenci INT,
			@maxDia INT;
		SET @maxDia = 
			CASE
				WHEN @numMesOp IN (1,3,5,7,8,10,12) THEN 31 --Meses de 31 d�as
				WHEN @numMesOp IN (4,6,9,11) THEN 30 --Meses de 30 d�as 
				WHEN (((@numA�oOp % 4) = 0 AND (@numA�oOp % 100) <> 0) OR (@numA�oOp % 400) = 0)
					THEN 29 --Si el a�o es biciesto, febrero tiene 29 d�as
				ELSE 28 --Si el a�o no es biciesto, febrero tiene 28 d�as
			END;
		SET @numA�oVenci = 
			CASE
				WHEN @numMesOp = 12 THEN @numA�oOp + 1
				ELSE @numA�oOp
			END;
		SET @numMesVenci =
			CASE
				WHEN @numMesOp = 12 THEN 1 --Evita que pase a 13
				ELSE @numMesOp + 1
			END;
		SET @numDiaVenci = 
			CASE
				WHEN (@numMesVenci <> 2 AND @numDiaOp <= 30) THEN @numDiaOp --La fecha de vencimiento queda el mismo d�a
				WHEN (@numMesVenci IN (1,3,5,7,8,10,12) AND @numDiaOp = @maxDia) THEN 31
				WHEN (@numMesVenci IN (4,6,9,11) AND @numDiaOp = @maxDia) THEN 30
				WHEN (@numMesVenci = 2 AND (((@numA�oOp % 4) = 0 AND (@numA�oOp % 100) <> 0) OR (@numA�oOp % 400) = 0))
					THEN 29
				ELSE 28
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
		WHERE DAY(P.FechaRegistro) = @numDiaOp --Propiedades con d�a de registro en el mismo d�a del mes
			OR (DAY(P.FechaRegistro) > @maxDia AND @maxDia = @numDiaOp); --O propiedades con d�a superior a la cantidad del mes
																			--cuando el d�a de operaci�n es el �ltimo del mes
		DECLARE @indexFinal INT = (SELECT MAX(Sec) FROM @PropCCTemp),
			@propCCIndex INT = 1,
			@idPropCC INT,
			@idPropiedad INT,
			@idCC INT,
			@m3Acum INT,
			@m3AcumFactAnt INT,
			@valor INT,
			@fechaRegistro DATE

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
					ELSE R.ValorMinimo + 75*CAST(((P.Area - R.ValorM2Minimo)/R.ValorTractosM2) AS INT)
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
				--Si no existe una factura para la propiedad con fecha de la operaci�n
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
							WHEN DAY(@fechaRegistro) > @maxDia THEN DATEFROMPARTS(@numA�oOp, @numMesOp, @maxDia) --Si el d�a de registro es mayor a los d�as del mes
							ELSE @inDate
						END,
						DATEFROMPARTS(@numA�oVenci, @numMesVenci, @numDiaVenci),
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
	SET @outResultMessage = 'Operaci�n exitosa';
	BEGIN TRY
		DECLARE @FactTemp TABLE(
			Sec INT IDENTITY (1,1),
			IdFactura INT,
			MontoOriginal INT);

		DECLARE	@numDiaOp INT = DAY(@inDate),
			@numMesOp INT = MONTH(@inDate),
			@numA�oOp INT = YEAR(@inDate),
			@maxDia INT;
		SET @maxDia = 
			CASE
				WHEN @numMesOp IN (1,3,5,7,8,10,12) THEN 31 --Meses de 31 d�as
				WHEN @numMesOp IN (4,6,9,11) THEN 30 --Meses de 30 d�as 
				WHEN (((@numA�oOp % 4) = 0 AND (@numA�oOp % 100) <> 0) OR (@numA�oOp % 400) = 0)
					THEN 29 --Si el a�o es biciesto, febrero tiene 29 d�as
				ELSE 28 --Si el a�o no es biciesto, febrero tiene 28 d�as
			END;

		DECLARE @idCCInteres INT,
			@tasaInteres FLOAT;	
		SELECT @idCCInteres = I.IdCC,
			@tasaInteres = I.ValorPorcentual
		FROM dbo.CCInteresesMoratorios AS I;
		
		INSERT INTO @FactTemp (
			IdFactura,
			MontoOriginal)
		SELECT F.Id,
			F.TotalOriginal
		FROM dbo.Factura AS F
		WHERE F.IdEstado = 1 AND (
			DAY(F.FechaVencimiento) = @numDiaOp --Propiedades con d�a de registro en el mismo d�a del mes
			OR (DAY(F.FechaVencimiento) > @maxDia AND @maxDia = @numDiaOp)); --O propiedades con d�a superior a la cantidad del mes
																			--cuando el d�a de operaci�n es el �ltimo del mes	
		DECLARE @finalIndex INT = (SELECT MAX(Sec) FROM @FactTemp),
			@factIndex INT = 1,
			@idFactura INT,
			@montoOriginal INT,
			@montoInteres INT;
			
		WHILE @finalIndex > @factIndex
		BEGIN
			SELECT @idFactura = F.IdFactura,
				@montoOriginal = F.MontoOriginal,
				@montoInteres = (F.MontoOriginal * @tasaInteres/12)
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

				UPDATE dbo.Factura WITH (ROWLOCK)
				SET TotalPagar = TotalPagar + @montoInteres
				WHERE Id = @idFactura;

			COMMIt TRANSACTION tIntereses
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
	SET @outResultMessage = 'Operaci�n exitosa';
	BEGIN TRY
		DECLARE @idCCReconexion INT,
			@monto INT;	
		SELECT @idCCReconexion = R.IdCC,
			@monto = R.ValorFijo
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
					WHERE PC.IdPropiedad = P.Id AND PC.IdConceptoCobro = 1)) --Que exista CCAgua en la propiedad
			AND NOT EXISTS (SELECT 1 
					FROM dbo.OrdenCorteAgua O 
					WHERE O.IdFactura = F.Id 
						AND O.Estado = 1) --Que no exista ya una orden de corte activa (Sin pagar)
			AND (F.Fecha = (SELECT MIN(F2.Fecha) 
					FROM dbo.Factura F2 
					WHERE F2.IdPropiedad = P.Id
						AND F2.IdEstado = 1)) --Que la factura seleccionada por propiedad sea la m�s antigua sin pagar
			AND (1 < (SELECT COUNT(1) 
					FROM dbo.Factura F3 
					WHERE F3.IdEstado = 1
						AND F3.IdPropiedad = P.Id)); --Que haya m�s de una factura pendiente asociada a la propiedad

		DECLARE @finalIndex INT = (SELECT MAX(Sec) FROM @OrdenTemp),
			@ordenIndex INT = 1,
			@idFactura INT,
			@idPropiedad INT;

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