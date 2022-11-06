USE [Servicios]
--Borra datos de las tablas
DELETE dbo.UsuarioXPropiedad;
DELETE dbo.PersonaXPropiedad;
DELETE dbo.CCAgua;
DELETE dbo.CCImpuestoPropiedad;
DELETE dbo.CCRecoleccionBasura;
DELETE dbo.CCPatenteComercial;
DELETE dbo.CCReconexion;
DELETE dbo.CCInteresesMoratorios;
DELETE dbo.CCMantenimientoParques;
DELETE dbo.PropiedadXConceptoCobro;
DELETE dbo.ConceptoCobro;
DELETE dbo.MovimientoConsumo;
DELETE dbo.PropiedadCCAgua;
DELETE dbo.DetalleCC;
DELETE dbo.Factura;
DELETE dbo.Usuario;
DELETE dbo.Persona;
DELETE dbo.Propiedad;

DELETE dbo.EstadoFactura
DELETE dbo.TipoDocumentoIdentidad;
DELETE dbo.TipoUsoPropiedad;
DELETE dbo.TipoZonaPropiedad;
DELETE dbo.TipoMovConsumo;
DELETE dbo.ParametroSistemaINT;
DELETE dbo.ParametroSistema;
DELETE dbo.TipoParametro
DELETE dbo.PeriodoMontoCC;
DELETE dbo.TipoMedioPago;
DELETE dbo.TipoMontoCC;

DECLARE @RutaXML NVARCHAR(512);
SET @RutaXML = 'D:\TEC\Semestre 6\Bases de datos\BD-Tarea3\SQL\Catalogos.xml'; --Direcci�n del XML.

DECLARE @Datos XML;
DECLARE @hdoc INT;

DECLARE @Comando NVARCHAR(512)= N'SELECT @Datos = D FROM OPENROWSET (BULK '+ CHAR(39) + @RutaXML + CHAR(39) + ', SINGLE_BLOB) AS Datos(D)' ;
DECLARE @Parametros NVARCHAR(4000);
SET @Parametros = N'@Datos XML OUTPUT';

EXECUTE sp_executesql @Comando, @Parametros, @Datos OUTPUT
EXECUTE sp_xml_preparedocument @hdoc OUTPUT, @Datos;


--Inserta a la tabla TipoMovLecturaMedidor
INSERT INTO dbo.TipoMovConsumo
		(Id
		,Nombre)
	SELECT id,
		Nombre
	FROM OPENXML (@hdoc, '/Catalogo/TipodeMovimientoLecturadeMedidores/TipodeMovimientoLecturadeMedidor', 1)
	WITH (id INT
		,Nombre VARCHAR(32));
		
--Inserta a la tabla TipoUsoPropiedad
INSERT INTO dbo.TipoUsoPropiedad
		(Id
		,Nombre)
	SELECT id,
		Nombre
	FROM OPENXML (@hdoc, '/Catalogo/TipoUsoPropiedades/TipoUsoPropiedad', 1)
	WITH (id INT
		,Nombre VARCHAR(32));
		
--Inserta a la tabla TipoZonaPropiedad
INSERT INTO dbo.TipoZonaPropiedad
		(Id
		,Nombre)
	SELECT id,
		Nombre
	FROM OPENXML (@hdoc, '/Catalogo/TipoZonaPropiedades/TipoZonaPropiedad', 1)
	WITH (id INT
		,Nombre VARCHAR(32));

--Inserta a la tabla TipoDocumentoIdentidad
INSERT INTO dbo.TipoDocumentoIdentidad
		(Id
		,Nombre)
	SELECT id,
		Nombre
	FROM OPENXML (@hdoc, '/Catalogo/TipoDocumentoIdentidades/TipoDocumentoIdentidad', 1)
	WITH (id INT
		,Nombre VARCHAR(32));
		
--Inserta a la tabla TipoMedioPago
INSERT INTO dbo.TipoMedioPago
		(Id
		,Nombre)
	SELECT id,
		Nombre
	FROM OPENXML (@hdoc, '/Catalogo/TipoMedioPagos/TipoMedioPago', 1)
	WITH (id INT
		,Nombre VARCHAR(32));

--Inserta a la tabla PeriodoMontoCC
INSERT INTO dbo.PeriodoMontoCC
		(Id
		,Nombre)
	SELECT id,
		Nombre
	FROM OPENXML (@hdoc, '/Catalogo/PeriodoMontoCCs/PeriodoMontoCC', 1)
	WITH (id INT
		,Nombre VARCHAR(32));
		
--Inserta a la tabla TipoMontoCC
INSERT INTO dbo.TipoMontoCC
		(Id
		,Nombre)
	SELECT id,
		Nombre
	FROM OPENXML (@hdoc, '/Catalogo/TipoMontoCCs/TipoMontoCC', 1)
	WITH (id INT
		,Nombre VARCHAR(32));

--Inserta en la tabla TipoParametro
INSERT INTO dbo.TipoParametro
	(Id,
	Nombre)
SELECT id,
	Nombre
FROM OPENXML (@hdoc, '/Catalogo/TipoParametroSistema/TipoParametro', 1)
WITH (id INT
	,Nombre VARCHAR(16));

--Inserta en la tabla ParametroSistema
INSERT INTO dbo.ParametroSistema (
	Id,
	IdTipoParametro,
	Nombre)
SELECT T.id,
	TP.Id,
	T.Nombre
FROM OPENXML (@hdoc, '/Catalogo/ParametrosSistema/ParametroSistema', 1)
WITH (id INT,
	NombreTipoPar VARCHAR(16),
	Nombre VARCHAR(128)) AS T
	INNER JOIN dbo.TipoParametro TP ON TP.Nombre = T.NombreTipoPar;	--Agrega el Id del tipo de parámetro

INSERT INTO dbo.ParametroSistemaINT (
	IdParametro,
	Valor)
SELECT id,
	Valor
FROM OPENXML (@hdoc, '/Catalogo/ParametrosSistema/ParametroSistema', 1)
WITH (id INT,
	Valor INT);

--Agrega los estados de factura
INSERT INTO dbo.EstadoFactura (
 Id,
 Nombre)
SELECT id,
	EstadoFactura
FROM OPENXML (@hdoc, '/Catalogo/EstadoDeFacturas/EstadoFactura', 1)
WITH (id INT,
	EstadoFactura VARCHAR(64));

--Se crea una tabla temporal para los Conceptos de cobro
DECLARE @TempCC TABLE(
		Id INT PRIMARY KEY,
		Nombre VARCHAR(32),
		TipoMontoCC INT,
		PeriodoMontoCC INT,
		ValorMinimo INT,
		ValorMinimoM3 INT,
		Valorm3 INT,
		ValorPorcentual FLOAT,
		ValorFijo INT,
		ValorM2Minimo INT,
		ValorTractosM2 INT,
		ValorFijoM3Adicional INT)

--Se insertan los CC en la tabla temporal
INSERT INTO @TempCC
	(Id,
	Nombre,
	TipoMontoCC,
	PeriodoMontoCC,
	ValorMinimo,
	ValorMinimoM3,
	Valorm3,
	ValorPorcentual,
	ValorFijo,
	ValorM2Minimo,
	ValorTractosM2,
	ValorFijoM3Adicional)
SELECT id,
	Nombre,
	TipoMontoCC,
	PeriodoMontoCC,
	ValorMinimo,
	ValorMinimoM3,
	Valorm3,
	ValorPorcentual,
	ValorFijo,
	ValorM2Minimo,
	ValorTractosM2,
	ValorFijoM3Adicional
FROM OPENXML (@hdoc, '/Catalogo/CCs/CC', 1)
WITH (id INT,
	Nombre VARCHAR(32),
	TipoMontoCC INT,
	PeriodoMontoCC INT,
	ValorMinimo INT,
	ValorMinimoM3 INT,
	Valorm3 INT,
	ValorPorcentual FLOAT,
	ValorFijo INT,
	ValorM2Minimo INT,
	ValorTractosM2 INT,
	ValorFijoM3Adicional INT);

DECLARE @FinalCCIndex INT = (SELECT MAX(Id) FROM @TempCC);
DECLARE @CCIndex INT = 1;
--Procesa iterativamente para separar los nodos por su nombre
WHILE (@FinalCCIndex >= @CCIndex)
BEGIN
	INSERT INTO dbo.ConceptoCobro
		(Id,
		IdPeriodoMontoCC,
		IdTipoMonto,
		Nombre)
	SELECT T.Id,
		T.PeriodoMontoCC,
		T.TipoMontoCC,
		T.Nombre
	FROM @TempCC T
	WHERE T.Id = @CCIndex;
	--Si el nombre es ConsumoAgua
	IF ((SELECT Nombre FROM @TempCC WHERE Id = @CCIndex) = 'ConsumoAgua')
	BEGIN
		INSERT INTO dbo.CCAgua
			(IdCC,
			MontoMinimo,
			MinimoM3,
			ValorFijoM3Adicional)
		SELECT T.Id,
			T.ValorMinimo,
			T.ValorMinimoM3,
			T.ValorFijoM3Adicional
		FROM @TempCC T
		WHERE T.Id = @CCIndex;
	END;
	--Si el nombre es Impuesto a propiedad
	IF ((SELECT Nombre FROM @TempCC WHERE Id = @CCIndex) = 'Impuesto a propiedad')
	BEGIN
		INSERT INTO dbo.CCImpuestoPropiedad
			(IdCC,
			ValorPorcentual)
		SELECT T.Id,
			T.ValorPorcentual
		FROM @TempCC T
		WHERE T.Id = @CCIndex;
	END;
	--Si el nombre es Recoleccion Basura
	IF ((SELECT Nombre FROM @TempCC WHERE Id = @CCIndex) = 'Recoleccion Basura')
	BEGIN
		INSERT INTO dbo.CCRecoleccionBasura
			(IdCC,
			ValorMinimo,
			ValorFijo,
			ValorM2Minimo,
			ValorTractosM2)
		SELECT T.Id,
			T.ValorMinimo,
			T.ValorFijo,
			T.ValorM2Minimo,
			T.ValorTractosM2
		FROM @TempCC T
		WHERE T.Id = @CCIndex;
	END;
	--Si el nombre es Patente Comercial
	IF ((SELECT Nombre FROM @TempCC WHERE Id = @CCIndex) = 'Patente Comercial')
	BEGIN
		INSERT INTO dbo.CCPatenteComercial
			(IdCC,
			ValorFijo)
		SELECT T.Id,
			T.ValorFijo
		FROM @TempCC T
		WHERE T.Id = @CCIndex;
	END;
	--Si el nombre es Reconexion
	IF ((SELECT Nombre FROM @TempCC WHERE Id = @CCIndex) = 'Reconexion')
	BEGIN
		INSERT INTO dbo.CCReconexion
			(IdCC,
			ValorFijo)
		SELECT T.Id,
			T.ValorFijo
		FROM @TempCC T
		WHERE T.Id = @CCIndex;
	END;
	--Si el nombre es Intereses Moratorios
	IF ((SELECT Nombre FROM @TempCC WHERE Id = @CCIndex) = 'Intereses Moratorios')
	BEGIN
		INSERT INTO dbo.CCInteresesMoratorios
			(IdCC,
			ValorPorcentual,
			ValorFijo)
		SELECT T.Id,
			T.ValorPorcentual,
			T.ValorFijo
		FROM @TempCC T
		WHERE T.Id = @CCIndex;
	END;
	--Si el nombre es MantenimientoParques
	IF ((SELECT Nombre FROM @TempCC WHERE Id = @CCIndex) = 'MantenimientoParques')
	BEGIN
		INSERT INTO dbo.CCMantenimientoParques
			(IdCC,
			ValorPorcentual,
			ValorFijo)
		SELECT T.Id,
			T.ValorPorcentual,
			T.ValorFijo
		FROM @TempCC T
		WHERE T.Id = @CCIndex;
	END;

	SET @CCIndex = @CCIndex + 1;
END;
