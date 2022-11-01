USE [master]
GO
/****** Object:  Database [Servicios]    Script Date: 10/4/2022 7:52:32 PM ******/
CREATE DATABASE [Servicios]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Servicios', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Servicios.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Servicios_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Servicios_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [Servicios] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Servicios].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Servicios] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Servicios] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Servicios] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Servicios] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Servicios] SET ARITHABORT OFF 
GO
ALTER DATABASE [Servicios] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Servicios] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Servicios] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Servicios] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Servicios] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Servicios] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Servicios] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Servicios] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Servicios] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Servicios] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Servicios] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Servicios] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Servicios] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Servicios] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Servicios] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Servicios] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Servicios] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Servicios] SET RECOVERY FULL 
GO
ALTER DATABASE [Servicios] SET  MULTI_USER 
GO
ALTER DATABASE [Servicios] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Servicios] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Servicios] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Servicios] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Servicios] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Servicios] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Servicios', N'ON'
GO
ALTER DATABASE [Servicios] SET QUERY_STORE = OFF
GO
USE [Servicios]
GO
/****** Object:  Table [dbo].[ConceptoCobro]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConceptoCobro](
	[Id] [int] NOT NULL,
	[IdPeriodoMontoCC] [int] NOT NULL,
	[IdTipoMedioPago] [int] NOT NULL,
	[IdTipoMonto] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
 CONSTRAINT [PK_ConceptoCobro] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DetalleCC]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DetalleCC](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdFactura] [int] NOT NULL,
	[IdConceptoCobro] [int] NOT NULL,
	[Monto] [int] NOT NULL,
 CONSTRAINT [PK_DetalleCC] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Factura]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Factura](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPropiedad] [int] NOT NULL,
	[IdDetalleCobro] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[FechaVencimiento] [date] NOT NULL,
	[TotalOriginal] [int] NOT NULL,
	[TotalPagar] [int] NOT NULL,
	[Estado] [int] NOT NULL,
 CONSTRAINT [PK_Factura] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MovimientoConsumo]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MovimientoConsumo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPropiedadCCAgua] [int] NOT NULL,
	[IdDetalleCCAgua] [int] NOT NULL,
	[IdTipoMovConsumo] [int] NULL,
	[NuevoSaldo] [int] NOT NULL,
 CONSTRAINT [PK_MovimientoConsumo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ParametroGeneral]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParametroGeneral](
	[Id] [int] NOT NULL,
	[IdTipoParametro] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
	[Valor] [varchar](32) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PeriodoMontoCC]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PeriodoMontoCC](
	[Id] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
 CONSTRAINT [PK_PeriodoMontoCC] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Persona]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Persona](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdTipoDocumentoIdentidad] [int] NOT NULL,
	[ValorDocumentoIdentidad] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
 CONSTRAINT [PK_Persona] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PersonaXPropiedad]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonaXPropiedad](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPersona] [int] NOT NULL,
	[IdPropiedad] [int] NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NULL,
 CONSTRAINT [PK_PersonaXPropiedad] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Propiedad]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Propiedad](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdTipoUsoPropiedad] [int] NOT NULL,
	[IdTipoZonaPropiedad] [int] NOT NULL,
	[Area] [int] NOT NULL,
	[ValorFiscal] [int] NOT NULL,
	[FechaRegistro] [date] NOT NULL,
 CONSTRAINT [PK_Propiedad] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PropiedadCCAgua]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropiedadCCAgua](
	[IdPropiedadXCC] [int] NOT NULL,
	[NumeroMedidor] [int] NOT NULL,
	[SaldoAcumulado] [int] NOT NULL,
 CONSTRAINT [PK_PropiedadCCAgua] PRIMARY KEY CLUSTERED 
(
	[IdPropiedadXCC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PropiedadXConceptoCobro]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropiedadXConceptoCobro](
	[Id] [int] NOT NULL,
	[IdPropiedad] [int] NOT NULL,
	[IdConceptoCobro] [int] NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
 CONSTRAINT [PK_PropiedadXConceptoCobro] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoDocumentoIdentidad]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoDocumentoIdentidad](
	[Id] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
 CONSTRAINT [PK_TipoDocumentoIdentidad] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoMedioPago]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoMedioPago](
	[Id] [int] NOT NULL,
	[Nombre] [varchar](32) NULL,
 CONSTRAINT [PK_TipoMedioPago] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoMontoCC]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoMontoCC](
	[Id] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
 CONSTRAINT [PK_TipoMontoCC] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoMovConsumo]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoMovConsumo](
	[Id] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
 CONSTRAINT [PK_TipoMovConsumo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoMovLecturaMedidor]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoMovLecturaMedidor](
	[Id] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
 CONSTRAINT [PK_TipoMovLecturaMedidor] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoParametro]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoParametro](
	[Id] [int] NOT NULL,
	[Nombre] [varchar](32) NULL,
 CONSTRAINT [PK_TipoParametro] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoUsoPropiedad]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoUsoPropiedad](
	[Id] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
 CONSTRAINT [PK_TipoUsoPropiedad] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TipoZonaPropiedad]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TipoZonaPropiedad](
	[Id] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
 CONSTRAINT [PK_TipoZonaPropiedad] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Usuario]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuario](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPersona] [int] NOT NULL,
	[Username] [varchar](32) NULL,
	[Password] [varchar](32) NULL,
	[TipoUsuario] [int] NULL,
 CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UsuarioXPropiedad]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsuarioXPropiedad](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[IdPropiedad] [int] NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NULL,
 CONSTRAINT [PK_UsuarioXPropiedad] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConceptoCobro]  WITH CHECK ADD  CONSTRAINT [FK_ConceptoCobro_PeriodoMontoCC] FOREIGN KEY([IdPeriodoMontoCC])
REFERENCES [dbo].[PeriodoMontoCC] ([Id])
GO
ALTER TABLE [dbo].[ConceptoCobro] CHECK CONSTRAINT [FK_ConceptoCobro_PeriodoMontoCC]
GO
ALTER TABLE [dbo].[ConceptoCobro]  WITH CHECK ADD  CONSTRAINT [FK_ConceptoCobro_TipoMedioPago] FOREIGN KEY([IdTipoMedioPago])
REFERENCES [dbo].[TipoMedioPago] ([Id])
GO
ALTER TABLE [dbo].[ConceptoCobro] CHECK CONSTRAINT [FK_ConceptoCobro_TipoMedioPago]
GO
ALTER TABLE [dbo].[ConceptoCobro]  WITH CHECK ADD  CONSTRAINT [FK_ConceptoCobro_TipoMontoCC] FOREIGN KEY([IdTipoMonto])
REFERENCES [dbo].[TipoMontoCC] ([Id])
GO
ALTER TABLE [dbo].[ConceptoCobro] CHECK CONSTRAINT [FK_ConceptoCobro_TipoMontoCC]
GO
ALTER TABLE [dbo].[DetalleCC]  WITH CHECK ADD  CONSTRAINT [FK_DetalleCC_ConceptoCobro] FOREIGN KEY([IdConceptoCobro])
REFERENCES [dbo].[ConceptoCobro] ([Id])
GO
ALTER TABLE [dbo].[DetalleCC] CHECK CONSTRAINT [FK_DetalleCC_ConceptoCobro]
GO
ALTER TABLE [dbo].[DetalleCC]  WITH CHECK ADD  CONSTRAINT [FK_DetalleCC_Factura] FOREIGN KEY([IdFactura])
REFERENCES [dbo].[Factura] ([Id])
GO
ALTER TABLE [dbo].[DetalleCC] CHECK CONSTRAINT [FK_DetalleCC_Factura]
GO
ALTER TABLE [dbo].[Factura]  WITH CHECK ADD  CONSTRAINT [FK_Factura_Propiedad] FOREIGN KEY([IdPropiedad])
REFERENCES [dbo].[Propiedad] ([Id])
GO
ALTER TABLE [dbo].[Factura] CHECK CONSTRAINT [FK_Factura_Propiedad]
GO
ALTER TABLE [dbo].[MovimientoConsumo]  WITH CHECK ADD  CONSTRAINT [FK_MovimientoConsumo_PropiedadCCAgua] FOREIGN KEY([IdPropiedadCCAgua])
REFERENCES [dbo].[PropiedadCCAgua] ([IdPropiedadXCC])
GO
ALTER TABLE [dbo].[MovimientoConsumo] CHECK CONSTRAINT [FK_MovimientoConsumo_PropiedadCCAgua]
GO
ALTER TABLE [dbo].[MovimientoConsumo]  WITH CHECK ADD  CONSTRAINT [FK_MovimientoConsumo_TipoMovConsumo] FOREIGN KEY([IdTipoMovConsumo])
REFERENCES [dbo].[TipoMovConsumo] ([Id])
GO
ALTER TABLE [dbo].[MovimientoConsumo] CHECK CONSTRAINT [FK_MovimientoConsumo_TipoMovConsumo]
GO
ALTER TABLE [dbo].[Persona]  WITH CHECK ADD  CONSTRAINT [FK_Persona_TipoDocumentoIdentidad1] FOREIGN KEY([IdTipoDocumentoIdentidad])
REFERENCES [dbo].[TipoDocumentoIdentidad] ([Id])
GO
ALTER TABLE [dbo].[Persona] CHECK CONSTRAINT [FK_Persona_TipoDocumentoIdentidad1]
GO
ALTER TABLE [dbo].[PersonaXPropiedad]  WITH CHECK ADD  CONSTRAINT [FK_PersonaXPropiedad_Persona] FOREIGN KEY([IdPersona])
REFERENCES [dbo].[Persona] ([Id])
GO
ALTER TABLE [dbo].[PersonaXPropiedad] CHECK CONSTRAINT [FK_PersonaXPropiedad_Persona]
GO
ALTER TABLE [dbo].[PersonaXPropiedad]  WITH CHECK ADD  CONSTRAINT [FK_PersonaXPropiedad_Propiedad] FOREIGN KEY([IdPropiedad])
REFERENCES [dbo].[Propiedad] ([Id])
GO
ALTER TABLE [dbo].[PersonaXPropiedad] CHECK CONSTRAINT [FK_PersonaXPropiedad_Propiedad]
GO
ALTER TABLE [dbo].[Propiedad]  WITH CHECK ADD  CONSTRAINT [FK_Propiedad_TipoUsoPropiedad] FOREIGN KEY([IdTipoUsoPropiedad])
REFERENCES [dbo].[TipoUsoPropiedad] ([Id])
GO
ALTER TABLE [dbo].[Propiedad] CHECK CONSTRAINT [FK_Propiedad_TipoUsoPropiedad]
GO
ALTER TABLE [dbo].[Propiedad]  WITH CHECK ADD  CONSTRAINT [FK_Propiedad_TipoZonaPropiedad] FOREIGN KEY([IdTipoZonaPropiedad])
REFERENCES [dbo].[TipoZonaPropiedad] ([Id])
GO
ALTER TABLE [dbo].[Propiedad] CHECK CONSTRAINT [FK_Propiedad_TipoZonaPropiedad]
GO
ALTER TABLE [dbo].[PropiedadCCAgua]  WITH CHECK ADD  CONSTRAINT [FK_PropiedadCCAgua_PropiedadXConceptoCobro] FOREIGN KEY([IdPropiedadXCC])
REFERENCES [dbo].[PropiedadXConceptoCobro] ([Id])
GO
ALTER TABLE [dbo].[PropiedadCCAgua] CHECK CONSTRAINT [FK_PropiedadCCAgua_PropiedadXConceptoCobro]
GO
ALTER TABLE [dbo].[PropiedadXConceptoCobro]  WITH CHECK ADD  CONSTRAINT [FK_PropiedadXConceptoCobro_ConceptoCobro] FOREIGN KEY([IdConceptoCobro])
REFERENCES [dbo].[ConceptoCobro] ([Id])
GO
ALTER TABLE [dbo].[PropiedadXConceptoCobro] CHECK CONSTRAINT [FK_PropiedadXConceptoCobro_ConceptoCobro]
GO
ALTER TABLE [dbo].[PropiedadXConceptoCobro]  WITH CHECK ADD  CONSTRAINT [FK_PropiedadXConceptoCobro_PersonaXPropiedad] FOREIGN KEY([IdPropiedad])
REFERENCES [dbo].[PersonaXPropiedad] ([Id])
GO
ALTER TABLE [dbo].[PropiedadXConceptoCobro] CHECK CONSTRAINT [FK_PropiedadXConceptoCobro_PersonaXPropiedad]
GO
ALTER TABLE [dbo].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Persona1] FOREIGN KEY([IdPersona])
REFERENCES [dbo].[Persona] ([Id])
GO
ALTER TABLE [dbo].[Usuario] CHECK CONSTRAINT [FK_Usuario_Persona1]
GO
ALTER TABLE [dbo].[UsuarioXPropiedad]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioXPropiedad_Propiedad1] FOREIGN KEY([IdPropiedad])
REFERENCES [dbo].[Propiedad] ([Id])
GO
ALTER TABLE [dbo].[UsuarioXPropiedad] CHECK CONSTRAINT [FK_UsuarioXPropiedad_Propiedad1]
GO
ALTER TABLE [dbo].[UsuarioXPropiedad]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioXPropiedad_Usuario] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuario] ([Id])
GO
ALTER TABLE [dbo].[UsuarioXPropiedad] CHECK CONSTRAINT [FK_UsuarioXPropiedad_Usuario]
GO
/****** Object:  StoredProcedure [dbo].[FindUser]    Script Date: 10/4/2022 7:52:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Selecciona el Id y tipo del usuario que coincide con el nombre y clave ingresados.
CREATE PROCEDURE [dbo].[FindUser]
		@inName VARCHAR(32),
		@inClave VARCHAR(32),
		@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0; 

	IF (@inName IS NULL OR LEN(@inName) = 0)
	BEGIN
		--Parametro inName nulo.
		SET @outResultCode = 50015;
		SELECT @outResultCode AS ResultCode
		RETURN;
	END;

	IF (@inClave IS NULL OR LEN(@inName) = 0)
	BEGIN
		--Parametro inClave nulo.
		SET @outResultCode = 50015; 
		SELECT @outResultCode AS ResultCode
		RETURN;
	END;

	IF NOT EXISTS (SELECT 1 FROM dbo.Usuario U WHERE (@inName = U.Username AND @inClave = U.Password))
	BEGIN
		SET @outResultCode = 50010; --No existe el par Usuario-Clave.
		SELECT @outResultCode AS ResultCode
		RETURN;
	END;

	SELECT @outResultCode AS ResultCode,
		U.Id,
		U.TipoUsuario
	FROM dbo.Usuario U
	WHERE (@inName = U.Username AND @inClave = U.Password);

	SET NOCOUNT OFF;
END
GO
USE [master]
GO
ALTER DATABASE [Servicios] SET  READ_WRITE 
GO
