USE [Servicios]

SET NOCOUNT ON;
DELETE dbo.DBErrors;
DELETE dbo.OrdenReconexion;
DELETE dbo.ComprobantePago;
DELETE dbo.OrdenCorteAgua;
DELETE dbo.DetalleCCAgua;
DELETE dbo.DetalleCC;
DELETE dbo.MovimientoConsumo;
DELETE dbo.PropiedadCCAgua;
DELETE dbo.PropiedadXConceptoCobro;
DElETE dbo.UsuarioXPropiedad;
DELETE dbo.PersonaXPropiedad;
DELETE dbo.PropiedadXConceptoCobro;

DELETE dbo.Factura
DELETE dbo.Propiedad;
DELETE dbo.Usuario;
DELETE dbo.Persona;

DBCC CHECKIDENT ('OrdenReconexion', RESEED, 0);
DBCC CHECKIDENT ('ComprobantePago', RESEED, 0);
DBCC CHECKIDENT ('OrdenCorteAgua', RESEED, 0);
DBCC CHECKIDENT ('DetalleCC', RESEED, 0);
DBCC CHECKIDENT ('PropiedadXConceptoCobro', RESEED, 0);
DBCC CHECKIDENT ('MovimientoConsumo', RESEED, 0);
DBCC CHECKIDENT ('UsuarioXPropiedad', RESEED, 0);
DBCC CHECKIDENT ('PersonaXPropiedad', RESEED, 0);
DBCC CHECKIDENT ('PropiedadXConceptoCobro', RESEED, 0);
DBCC CHECKIDENT ('Factura', RESEED, 0);
DBCC CHECKIDENT ('Propiedad', RESEED, 0);
DBCC CHECKIDENT ('Usuario', RESEED, 0);
DBCC CHECKIDENT ('Persona', RESEED, 0);

DECLARE @RutaXML NVARCHAR(512);
SET @RutaXML = 'D:\TEC\Semestre 6\Bases de datos\BD-Tarea3\SQL\Operaciones.xml'; --Dirección del XML.

DECLARE @Datos XML;
DECLARE @hdoc INT;

DECLARE @Comando NVARCHAR(512)= N'SELECT @Datos = D FROM OPENROWSET (BULK '+ CHAR(39) + @RutaXML + CHAR(39) + ', SINGLE_BLOB) AS Datos(D)' ;
DECLARE @Parametros NVARCHAR(4000);
SET @Parametros = N'@Datos XML OUTPUT';

EXECUTE sp_executesql @Comando, @Parametros, @Datos OUTPUT
EXECUTE sp_xml_preparedocument @hdoc OUTPUT, @Datos;

DECLARE @ResultCode INT;
DECLARE @ResultMessage VARCHAR(64);
DECLARE @iter INT = 1;
DECLARE @nodoFecha NVARCHAR(512);
DECLARE @Date DATE;
DECLARE @nodoPersona NVARCHAR(512);
DECLARE @nodoUsuario NVARCHAR(512);
DECLARE @nodoPropiedad NVARCHAR(512);
DECLARE @nodoAsoPP NVARCHAR(512);
DECLARE @nodoAsoUP NVARCHAR(512);
DECLARE @nodoLectura NVARCHAR(512);
DECLARE @nodoPago NVARCHAR(512);
--Crea una tabla temporal para guardar las fechas de operación
DECLARE @DateTemp TABLE (
		Id INT PRIMARY KEY IDENTITY,
		Fecha DATE);

SET @nodoFecha = '/Datos/Operacion';
--Inserta las fechas en la tabla temporal
INSERT INTO @DateTemp (Fecha)
	SELECT Fecha
	FROM OPENXML (@hdoc, @nodoFecha, 1)
	WITH (Fecha DATE);

--Crea una variable con el valor máximo de Id de la tabla temporal para saber las iteraciones que se deben realizar
DECLARE @FinalIter INT = (SELECT MAX(Id) FROM @DateTemp);
WHILE (@FinalIter >= @iter)
BEGIN	
	SET @nodoPersona = '/Datos/Operacion[' + CAST(@iter AS VARCHAR(8)) + ']/Personas/Persona';
	SET @nodoUsuario = '/Datos/Operacion[' + CAST(@iter AS VARCHAR(8)) + ']/Usuario/Usuario';
	SET @nodoPropiedad = '/Datos/Operacion[' + CAST(@iter AS VARCHAR(8)) + ']/Propiedades/Propiedad';
	SET @nodoAsoPP = '/Datos/Operacion[' + CAST(@iter AS VARCHAR(8)) + ']/PersonasyPropiedades/PropiedadPersona';
	SET @nodoAsoUP = '/Datos/Operacion[' + CAST(@iter AS VARCHAR(8)) + ']/PropiedadesyUsuarios/UsuarioPropiedad';
	SET @nodoLectura = '/Datos/Operacion[' + CAST(@iter AS VARCHAR(8)) + ']/Lecturas/LecturaMedidor';
	SET @nodoPago = '/Datos/Operacion[' + CAST(@iter AS VARCHAR(8)) + ']/Pago/Pago';
	SET @Date = (SELECT Fecha FROM @DateTemp WHERE Id = @iter);

	--Declara las variables tablas
	DECLARE @PropiedadTemp AS  dbo.TProp;
	DECLARE @AsoPPTemp AS dbo.TAsoPP; --Se crea la tabla temporal para insertar las asociaciones de personas/propiedades 
	DECLARE @UserTemp AS dbo.TUser;
	DECLARE @AsoUPTemp AS dbo.TAsoUP;
	DECLARE @LecturaTemp AS dbo.TLectura;
	DECLARE @PagoTemp AS dbo.TPago;

	--Inserta en las avariables tablas
	INSERT INTO @PropiedadTemp(
		SEC,
		TipoUsoPropiedad, --Guarda el nombre del tipo de Uso/Zona, no el Id
		TipoZonaPropiedad,
		NumeroFinca,
		Area,
		ValorFiscal,
		NumeroMedidor)
	SELECT Row_Number() OVER ( ORDER BY P.NumeroFinca ),
		P.tipoUsoPropiedad,
		P.tipoZonaPropiedad,
		P.NumeroFinca,
		P.MetrosCuadrados,
		P.ValorFiscal,
		P.NumeroMedidor
	FROM OPENXML (@hdoc, @nodoPropiedad, 1)
	WITH (NumeroFinca INT,
		MetrosCuadrados INT,
		ValorFiscal BIGINT,
		NumeroMedidor INT,
		tipoUsoPropiedad VARCHAR(32),
		tipoZonaPropiedad VARCHAR(32)) AS P;

	INSERT INTO @AsoPPTemp(
		SEC,
		ValDocPersona, --Guarda el nombre del tipo de Uso/Zona, no el Id
		NumFinca,
		TipoAsociacion)
	SELECT Row_Number() OVER ( ORDER BY A.NumeroFinca ),
		A.ValorDocumentoIdentidad,
		A.NumeroFinca,
		A.TipoAsociacion
	FROM OPENXML (@hdoc, @nodoAsoPP, 1)
	WITH (ValorDocumentoIdentidad INT,
		NumeroFinca INT,
		TipoAsociacion VARCHAR(16)) AS A;

	INSERT INTO @UserTemp (
		SEC,
		ValDocPersona,
		Username,
		Password,
		TipoUsuario,
		TipoAsociacion)
	SELECT Row_Number() OVER ( ORDER BY U.ValorDocumentoIdentidad ),
		U.ValorDocumentoIdentidad,
		U.Username,
		U.Password,
		U.TipoUsuario,
		U.TipoAsociacion
	FROM OPENXML (@hdoc, @nodoUsuario, 1)
	WITH (ValorDocumentoIdentidad INT,
		Username VARCHAR(32),
		Password VARCHAR(32),
		TipoUsuario  VARCHAR(16),
		TipoAsociacion VARCHAR(16)) AS U;

	INSERT INTO @AsoUPTemp(
		SEC,
		ValDocPersona,
		NumFinca,
		TipoAsociacion)
	SELECT Row_Number() OVER ( ORDER BY A.NumeroFinca ),
		A.ValorDocumentoIdentidad,
		A.NumeroFinca,
		A.TipoAsociacion
	FROM OPENXML (@hdoc, @nodoAsoUP, 1)
	WITH (ValorDocumentoIdentidad INT,
		NumeroFinca INT,
		TipoAsociacion VARCHAR(16)) AS A;

	INSERT INTO @LecturaTemp(
		SEC,
		NumeroMedidor,
		TipoMovimiento,
		Valor)
	SELECT Row_Number() OVER ( ORDER BY L.NumeroMedidor ), 
		L.NumeroMedidor,
		L.TipoMovimiento,
		L.Valor
	FROM OPENXML (@hdoc, @nodoLectura, 1)
	WITH (NumeroMedidor INT,
		TipoMovimiento VARCHAR(32),
		Valor INT) AS L;

	INSERT INTO @PagoTemp (
		SEC,
		NumeroFinca,
		TipoPago,
		NumeroReferencia)
	SELECT Row_Number() OVER ( ORDER BY P.NumFinca),
		P.NumFinca,
		P.TipoPago,
		P.NumeroReferenciaComprobantePago
	FROM OPENXML (@hdoc, @nodoPago, 1)
	WITH (NumFinca INT,
		TipoPago VARCHAR(64),
		NumeroReferenciaComprobantePago INT) AS P;


	--Declara las variables para controlar los while
	DECLARE @PropertyFinalIndex INT = (SELECT MAX(SEC) FROM @PropiedadTemp);
	DECLARE @PropertyIndex INT = 1;
	DECLARE @AsoPPFinalIndex INT = (SELECT MAX(SEC) FROM @AsoPPTemp);
	DECLARE @AsoPPIndex INT = 1;
	DECLARE @FinalUserIndex INT = (SELECT MAX(SEC) FROM @UserTemp);
	DECLARE @UserIndex INT = 1;
	DECLARE @AsoUPFinalIndex INT = (SELECT MAX(Id) FROM @AsoUPTemp);
	DECLARE @AsoUPIndex INT = 1;

	--Procesar nuevas personas
	INSERT INTO dbo.Persona(
		IdTipoDocumentoIdentidad,
		ValorDocumentoIdentidad,
		Nombre,
		Email,
		Telefono1,
		Telefono2)
		SELECT TDoc.Id,	--Agrega el Id que coincida con el tipo
			P.ValorDocumentoIdentidad,
			P.Nombre,
			P.Email,
			P.Telefono1,
			P.Telefono2
		FROM OPENXML (@hdoc, @nodoPersona, 1)
		WITH (TipoDocumentoIdentidad VARCHAR(32),
			ValorDocumentoIdentidad INT,
			Nombre VARCHAR(32),
			Email VARCHAR(32),
			Telefono1 INT,
			Telefono2 INT) AS P
			INNER JOIN dbo.TipoDocumentoIdentidad AS TDOC ON TDOC.Nombre = P.TipoDocumentoIdentidad; --Obtiene el tipo que le corresponde

	--Procesar nuevas propiedades
	WHILE (@PropertyFinalIndex >= @PropertyIndex) --Hace un WHiLE para insertar cada nueva propiedad en la tabla de propiedades y asociarle los servicios correspondientes
	BEGIN
		EXEC dbo.PropiedadXML @PropiedadTemp, @PropertyIndex, @Date, @ResultCode OUTPUT, @ResultMessage OUTPUT;
		SET @PropertyIndex = @PropertyIndex + 1;
	END; --Fin del WHILE que procesa nuevas propiedades
		
	--Procesar asociaciones Persona/Propiedad
	WHILE (@AsoPPFinalIndex >= @AsoPPIndex)
	BEGIN
		EXEC dbo.AsoPPXML @AsoPPTemp, @AsoPPIndex, @Date, @ResultCode OUTPUT, @ResultMessage OUTPUT;
		SET @AsoPPIndex = @AsoPPIndex + 1;
	END; --Fin del WHILE para PersonaXPropiedad
		
	--Procesar usuarios
	WHILE (@FinalUserIndex >= @UserIndex)
	BEGIN
		EXEC dbo.UserXML @UserTemp, @UserIndex, @Date, @ResultCode OUTPUT, @ResultMessage OUTPUT;
		SET @UserIndex = @UserIndex + 1;
	END; --Fin del WHILE de usuarios

	--Procesar asociaciones Usuario/Propiedad
	WHILE (@AsoUPFinalIndex >= @AsoUPIndex)
	BEGIN
		EXEC AsoUPXML @AsoUPTemp, @AsoUPIndex, @Date, @ResultCode OUTPUT, @ResultMessage OUTPUT;
		SET @AsoUPIndex = @AsoUPIndex + 1;
	END; --Fin del WHILE de UsuarioXPropiedad

	--Procesar lecturas
	EXEC dbo.LecturasXML @LecturaTemp, @Date, @ResultCode OUTPUT, @ResultMessage OUTPUT;

	--Procesar pagos
	EXEC dbo.PagosXML @PagoTemp, @Date, @ResultCode OUTPUT, @ResultMessage OUTPUT;

	--Generar facturas
	EXEC dbo.GenerarFacturas @Date, @ResultCode OUTPUT, @ResultMessage OUTPUT;

	--Genera los detallesCC por Intereses moratorios
	EXEC dbo.GenerarIntereses @Date, @ResultCode OUTPUT, @ResultMessage OUTPUT;

	--Genera ordenes de corte
	EXEC dbo.GenerarOrdenCorte @Date, @ResultCode OUTPUT, @ResultMessage OUTPUT;

	--Se eliminan las variables tablas
	DELETE @PropiedadTemp;
	DELETE @AsoPPTemp;
	DELETE @UserTemp;
	DELETE @AsoUPTemp;
	DELETE @LecturaTemp;
	DELETE @PagoTemp;
	--Se incrementa iter
	SET @iter = @iter + 1;
END; --Fin del WHILE general

select * from OrdenCorteAgua
select * from OrdenReconexion
select * from ComprobantePago C where C.IdFactura = 441
select * from Factura