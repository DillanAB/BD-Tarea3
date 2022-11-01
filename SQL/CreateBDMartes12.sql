USE [master]
GO
/****** Object:  Database [Servicios]    Script Date: 10/12/2022 7:36:23 AM ******/
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
/****** Object:  Table [dbo].[ConceptoCobro]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[DetalleCC]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[Factura]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[MovimientoConsumo]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[ParametroGeneral]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[PeriodoMontoCC]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[Persona]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Persona](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdTipoDocumentoIdentidad] [int] NOT NULL,
	[ValorDocumentoIdentidad] [int] NOT NULL,
	[Nombre] [varchar](32) NOT NULL,
	[Email] [varchar](32) NOT NULL,
	[Telefono1] [int] NOT NULL,
	[Telefono2] [int] NOT NULL,
	[Activo] [int] NOT NULL,
 CONSTRAINT [PK_Persona] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PersonaXPropiedad]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[Propiedad]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Propiedad](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdTipoUsoPropiedad] [int] NOT NULL,
	[IdTipoZonaPropiedad] [int] NOT NULL,
	[NumeroFinca] [int] NOT NULL,
	[Area] [int] NOT NULL,
	[ValorFiscal] [bigint] NOT NULL,
	[NumeroMedidor] [int] NOT NULL,
	[FechaRegistro] [date] NOT NULL,
	[Activo] [int] NOT NULL,
 CONSTRAINT [PK_Propiedad] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PropiedadCCAgua]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[PropiedadXConceptoCobro]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[TipoDocumentoIdentidad]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[TipoMedioPago]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[TipoMontoCC]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[TipoMovConsumo]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[TipoMovLecturaMedidor]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[TipoParametro]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[TipoUsoPropiedad]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[TipoZonaPropiedad]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  Table [dbo].[Usuario]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuario](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdPersona] [int] NOT NULL,
	[Username] [varchar](32) NOT NULL,
	[Password] [varchar](32) NOT NULL,
	[TipoUsuario] [int] NOT NULL,
	[Activo] [int] NOT NULL,
 CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UsuarioXPropiedad]    Script Date: 10/12/2022 7:36:24 AM ******/
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
ALTER TABLE [dbo].[Persona] ADD  CONSTRAINT [DF_Persona_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[Propiedad] ADD  CONSTRAINT [DF_Propiedad_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [dbo].[Usuario] ADD  CONSTRAINT [DF_Usuario_Activo]  DEFAULT ((1)) FOR [Activo]
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
ALTER TABLE [dbo].[PropiedadXConceptoCobro]  WITH CHECK ADD  CONSTRAINT [FK_PropiedadXConceptoCobro_Propiedad] FOREIGN KEY([IdPropiedad])
REFERENCES [dbo].[Propiedad] ([Id])
GO
ALTER TABLE [dbo].[PropiedadXConceptoCobro] CHECK CONSTRAINT [FK_PropiedadXConceptoCobro_Propiedad]
GO
ALTER TABLE [dbo].[Usuario]  WITH CHECK ADD  CONSTRAINT [FK_Usuario_Persona] FOREIGN KEY([IdPersona])
REFERENCES [dbo].[Persona] ([Id])
GO
ALTER TABLE [dbo].[Usuario] CHECK CONSTRAINT [FK_Usuario_Persona]
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
/****** Object:  StoredProcedure [dbo].[CreateAsoPP]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CreateAsoPP]
	@inDocVal INT,
	@inNumFinca INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
    SET @outResultMessage = 'Operación exitosa'

	--Revisa si hay algun parámetro de entrada nulo
	IF (@inDocVal IS NULL OR @inDocVal <= 0
		OR @inNumFinca IS NULL OR @inNumFinca <= 0)
	BEGIN
		SET @outResultCode = 50015;
		SET  @outResultMessage = 'Parametros faltantes.';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	--Verifica si ya existe una relación sin fecha de fin entre la propiedad y la persona 
	IF EXISTS (SELECT 1 
			FROM dbo.PersonaXPropiedad PP
			INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
			INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad
			WHERE PE.ValorDocumentoIdentidad = @inDocVal
				AND PR.NumeroFinca = @inNumFinca
				AND PP.FechaFin IS NULL)
	BEGIN
		SET @outResultCode = 50025;
		SET  @outResultMessage = 'Ya existe una relación activa entre la persona y la propiedad.';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	INSERT INTO dbo.PersonaXPropiedad(
		[IdPersona],
		[IdPropiedad],
		[FechaInicio])
		SELECT PE.Id,
			PR.Id,
			GETDATE()
		FROM dbo.Persona AS PE,
			dbo.Propiedad AS PR
		WHERE PE.ValorDocumentoIdentidad = @inDocVal
			AND PR.NumeroFinca = @inNumFinca;

	SELECT @outResultCode AS ResultCode,
		@outResultMessage AS ResultMessage;

	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[CreateAsoUP]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CreateAsoUP]
	@inUsername VARCHAR(32),
	@inNumFinca INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
    SET @outResultMessage = 'Operación exitosa'

	--Revisa si hay algun parámetro de entrada nulo
	IF (@inUsername IS NULL OR LEN(@inUsername) = 0
		OR @inNumFinca IS NULL OR @inNumFinca <= 0)
	BEGIN
		SET @outResultCode = 50015;
		SET  @outResultMessage = 'Parametros faltantes.';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	--Verifica si ya existe una relación sin fecha de fin entre la propiedad y usuario
	IF EXISTS (SELECT 1 
			FROM dbo.UsuarioXPropiedad UP
			INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
			INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad
			WHERE U.Username = @inUsername
				AND PR.NumeroFinca = @inNumFinca
				AND UP.FechaFin IS NULL)
	BEGIN
		SET @outResultCode = 50025;
		SET  @outResultMessage = 'Ya existe una relación activa entre el ususario y la propiedad.';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	INSERT INTO dbo.UsuarioXPropiedad(
		[IdUsuario],
		[IdPropiedad],
		[FechaInicio])
		SELECT U.Id,
			PR.Id,
			GETDATE()
		FROM dbo.Usuario AS U,
			dbo.Propiedad AS PR
		WHERE U.Username = @inUsername
			AND PR.NumeroFinca = @inNumFinca;

	SELECT @outResultCode AS ResultCode,
		@outResultMessage AS ResultMessage;

	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[CreatePerson]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Inserta en la tabla Persona
CREATE PROCEDURE [dbo].[CreatePerson]
	@inName VARCHAR(32),
	@inIdTipoDoc INT,
	@inValorDoc INT,
	@outResultCode INT OUTPUT,
	@outErrorMessage VARCHAR OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;

	--Revisa si hay algún parámentro de entrada nulo
	IF (@inName IS NULL OR LEN(@inName) = 0
		OR @inIdTipoDoc IS NULL
		OR @inValorDoc IS NULL)
	BEGIN
		SET @outResultCode = 50015;
		SET  @outErrorMessage = 'Parámetros faltantes.';
		SELECT @outResultCode AS ResultCode,
			@outErrorMessage AS ResultMessage;
		RETURN;
	END;

	IF EXISTS (SELECT 1 FROM dbo.Persona WHERE ValorDocumentoIdentidad = @inValorDoc) --Si hay una persona con misma identificación
	BEGIN
		SET @outResultCode = 50002;
		SET  @outErrorMessage = 'Persona con identificación repetida.';
		SELECT  @outResultCode AS ResultCode,
			@outErrorMessage AS ResultMessage;
		RETURN;
	END;

	SELECT @outResultCode AS ResultCode; --Envia el código de error a la web
	INSERT INTO dbo.Persona(
		IdTipoDocumentoIdentidad,
		ValorDocumentoIdentidad,
		Nombre)
		SELECT @inIdTipoDoc,
			@inValorDoc,
			@inName;
	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[CreateProperty]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Inserta en la tabla Propiedad
CREATE PROCEDURE [dbo].[CreateProperty]
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
	SET @outResultCode = 0;
    SET @outResultMessage = 'Operación exitosa'

	--Reemplaza guiones por espacios para que coincida con los valores de la tabla TipoUsoPropiedad 
	SET @inUseType = REPLACE(@inUseType, N'-', N' ');
	--Reemplaza guiones por espacios para que coincida con los valores de la tabla TipoZonaPropiedad 
	SET @inZoneType = REPLACE(@inZoneType, N'-', N' ');

	--Revisa si hay algun parámetro de entrada nulo
	IF (@inUseType IS NULL OR LEN(@inUseType) = 0
		OR @inZoneType IS NULL OR LEN(@inZoneType) = 0
		OR @inFincNum <= 0
		OR @inArea <= 0
		OR @inFiscalValue <= 0
		OR @inMedNum <= 0
		OR @inDate IS NULL OR LEN(@inDate) = 0)
	BEGIN
		SET @outResultCode = 50015;
		SET  @outResultMessage = 'Parametros faltantes.';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	--Si existe una propiedad con el mismo número de finca
	IF EXISTS (SELECT 1 FROM dbo.Propiedad P WHERE P.NumeroFinca = @inFincNum)
	BEGIN
		SET @outResultCode = 50025;
		SET  @outResultMessage = 'Ya existe una propiedad con el número de finca.';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

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
		FROM dbo.Propiedad AS P
		INNER JOIN dbo.TipoUsoPropiedad AS TU ON TU.Nombre = @inUseType
		INNER JOIN dbo.TipoZonaPropiedad AS TZ ON TZ.Nombre = @inZoneType

	SELECT @outResultCode AS ResultCode,
		@outResultMessage AS ResultMessage;

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[CreateUser]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Inserta en la tabla Usuario
CREATE PROCEDURE [dbo].[CreateUser]
    @inIdPerson INT,
	@inUsername VARCHAR(32),
    @inPassword VARCHAR(32),
	@inUserType INT,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
    --SET @outErrorMessage = '';


	--Revisa si hay alg�n par�mentro de entrada nulo
	IF (@inUsername IS NULL OR LEN(@inUsername) = 0
        OR @inPassword IS NULL OR LEN(@inPassword) = 0
		OR @inIdPerson IS NULL
		OR @inUserType IS NULL)
	BEGIN
		SET @outResultCode = 50015;
		--SET  @outErrorMessage = 'Par�metros faltantes.';
		SELECT @outResultCode AS ResultCode;
			--@outErrorMessage AS ResultMessage;
		RETURN;
	END;

	IF EXISTS (SELECT 1 FROM dbo.Usuario WHERE Username = @inUsername) --Si hay un usuario con mismo username
	BEGIN
		SET @outResultCode = 50002;
		--SET  @outErrorMessage = 'Nombre de usuario repetido.';
		SELECT  @outResultCode AS ResultCode;
			--@outErrorMessage AS ResultMessage;
		RETURN;
	END;

	SELECT @outResultCode AS ResultCode --Envia el c�digo de error a la web
	INSERT INTO dbo.Usuario(
		IdPersona,
		Username,
		Password,
        TipoUsuario)
		SELECT P.Id,
			@inUsername,
			@inPassword,
            @inUserType
			FROM dbo.Persona AS P 
			WHERE P.ValorDocumentoIdentidad = @inIdPerson;
	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteAsoPP]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteAsoPP]
	@inDocVal INT,
	@inNumFinca INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
    SET @outResultMessage = 'Operación exitosa'

	--Revisa si hay algun parámetro de entrada nulo
	IF (@inDocVal IS NULL OR @inDocVal <= 0
		OR @inNumFinca IS NULL OR @inNumFinca <= 0)
	BEGIN
		SET @outResultCode = 50015;
		SET  @outResultMessage = 'Parametros faltantes.';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	--Verifica si existe una relación activa entre la propiedad y la persona 
	IF NOT EXISTS (SELECT 1 
			FROM dbo.PersonaXPropiedad PP
			INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
			INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad
			WHERE PE.ValorDocumentoIdentidad = @inDocVal
				AND PR.NumeroFinca = @inNumFinca
				AND PP.FechaFin IS NULL)
	BEGIN
		SET @outResultCode = 50025;
		SET  @outResultMessage = 'No existe una relación activa entre la persona y la propiedad.';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	Update dbo.PersonaXPropiedad
		SET FechaFin = GETDATE()
		FROM dbo.PersonaXPropiedad AS PP
		INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
		INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad
		WHERE PE.ValorDocumentoIdentidad = @inDocVal
			AND PR.NumeroFinca = @inNumFinca;

	SELECT @outResultCode AS ResultCode,
		@outResultMessage AS ResultMessage;

	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteAsoUP]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteAsoUP]
	@inUsername VARCHAR(32),
	@inNumFinca INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
    SET @outResultMessage = 'Operación exitosa'

	--Revisa si hay algun parámetro de entrada nulo
	IF (@inUsername IS NULL OR LEN(@inUsername) = 0
		OR @inNumFinca IS NULL OR @inNumFinca <= 0)
	BEGIN
		SET @outResultCode = 50015;
		SET  @outResultMessage = 'Parametros faltantes.';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	--Verifica si existe una relación activa entre la propiedad y usuario
	IF NOT EXISTS (SELECT 1 
			FROM dbo.UsuarioXPropiedad UP
			INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
			INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad
			WHERE U.Username = @inUsername
				AND PR.NumeroFinca = @inNumFinca
				AND UP.FechaFin IS NULL)
	BEGIN
		SET @outResultCode = 50025;
		SET  @outResultMessage = 'No existe una relación activa entre la persona y la propiedad.';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	Update dbo.UsuarioXPropiedad
		SET FechaFin = GETDATE()
		FROM dbo.UsuarioXPropiedad AS UP
		INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
		INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad
		WHERE U.Username = @inUsername
			AND PR.NumeroFinca = @inNumFinca;

	SELECT @outResultCode AS ResultCode,
		@outResultMessage AS ResultMessage;

	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteProperty]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Desactiva una propiedad, se selecciona por número de finca
CREATE PROCEDURE [dbo].[DeleteProperty]
	@inNumFinc INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(62) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';
		
	IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE NumeroFinca = @inNumFinc)
	BEGIN
		SET @outResultCode = 50004;
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

	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteUser]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Encuentra un usuario por nombre y cambia el valor de activo a 0
CREATE PROCEDURE [dbo].[DeleteUser]
	@inUsername VARCHAR(32),
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';

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

	SET  NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[FindUser]    Script Date: 10/12/2022 7:36:24 AM ******/
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
/****** Object:  StoredProcedure [dbo].[GetPropietarios]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetPropietarios]
	@inNumFinca INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PE.[Id] AS IdPersona,
	PE.[ValorDocumentoIdentidad],
	PE.[Nombre],
	PE.[Activo],
	PP.[FechaInicio],
	PP.[FechaFin]
	FROM dbo.PersonaXPropiedad AS PP
		INNER JOIN dbo.Propiedad AS P ON P.Id = PP.IdPropiedad
		INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
	WHERE P.NumeroFinca = @inNumFinca; --Selecciona los que tienen el mismo número de finca

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[GetPropsFromPerson]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetPropsFromPerson]
	@inName VARCHAR(32),
	@inDocVal INT,
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT P.[Id],
		P.[IdTipoUsoPropiedad],
		P.[IdTipoZonaPropiedad],
		P.[NumeroFinca],
		P.[Area],
		P.[ValorFiscal],
		P.[NumeroMedidor],
		P.[FechaRegistro],
		P.[Activo]
	FROM dbo.PersonaXPropiedad AS PP
		INNER JOIN dbo.Propiedad AS P ON P.Id = PP.IdPropiedad
		INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
	WHERE PE.ValorDocumentoIdentidad = @inDocVal;

	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[ReadAsoPP]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ReadAsoPP]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT PP.Id,
		PE.ValorDocumentoIdentidad AS IdentificacionPersona,
		PR.NumeroFinca,
		PP.FechaInicio,
		PP.FechaFin
	FROM dbo.PersonaXPropiedad AS PP
	INNER JOIN dbo.Persona AS PE ON PE.Id = PP.IdPersona
	INNER JOIN dbo.Propiedad AS PR ON PR.Id = PP.IdPropiedad;
	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[ReadAsoUP]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ReadAsoUP]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT UP.Id,
		U.Username,
		PR.NumeroFinca,
		UP.FechaInicio,
		UP.FechaFin
	FROM dbo.UsuarioXPropiedad AS UP
	INNER JOIN dbo.Usuario AS U ON U.Id = UP.IdUsuario
	INNER JOIN dbo.Propiedad AS PR ON PR.Id = UP.IdPropiedad;

	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[ReadPerson]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ReadPerson]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT P.Id,
		P.IdTipoDocumentoIdentidad,
		P.ValorDocumentoIdentidad,
		P.Nombre,
		P.Activo
	FROM dbo.Persona AS P; 
	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[ReadProperty]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ReadProperty]
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
		P.FechaRegistro,
		P.Activo
		FROM dbo.Propiedad AS P
		INNER JOIN dbo.TipoUsoPropiedad AS TU ON TU.Id = P.IdTipoUsoPropiedad
		INNER JOIN dbo.TipoZonaPropiedad AS TZ ON TZ.Id = P.IdTipoZonaPropiedad
		ORDER BY P.NumeroFinca;
	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[ReadUse]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ReadUse]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM dbo.TipoUsoPropiedad;
	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[ReadUser]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Seleccionade la tabla Usuario
CREATE PROCEDURE [dbo].[ReadUser]
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
/****** Object:  StoredProcedure [dbo].[ReadZone]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ReadZone]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM dbo.TipoZonaPropiedad;
	SET NOCOUNT OFF;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateProperty]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateProperty]
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
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';

	--Reemplaza guiones por espacios para que coincida con los valores de la tabla TipoUsoPropiedad 
	SET @inNewUse = REPLACE(@inNewUse, N'-', N' ');
	--Reemplaza guiones por espacios para que coincida con los valores de la tabla TipoZonaPropiedad 
	SET @inNewZone = REPLACE(@inNewZone, N'-', N' ');

	--Si no existe el número de finca
	IF NOT EXISTS (SELECT 1 FROM dbo.Propiedad WHERE NumeroFinca = @inNumFinc)
	BEGIN
		SET @outResultCode = 50004;
		SET @outResultMessage = 'No existe la propiedad';
		SELECT @outResultCode AS ResultCode,
			@outResultMessage AS ResultMessage;
		RETURN;
	END;

	--Actualiza el tipo de uso si se ingresó un nuevo valor
	IF (LEN(@inNewUse) > 0 AND @inNewUse IS NOT NULL)
	BEGIN
		UPDATE dbo.Propiedad
			SET IdTipoUsoPropiedad = TU.Id
			FROM dbo.Propiedad AS P
			INNER JOIN dbo.TipoUsoPropiedad AS TU ON TU.Nombre = @inNewUse
			WHERE P.NumeroFinca = @inNumFinc;
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

	--Actualiza el número de finca si se ingresó un nuevo valor
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

	SET NOCOUNT OFF;
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateUser]    Script Date: 10/12/2022 7:36:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Busca un usuario por su username y actualiza los valores solicitados
CREATE PROCEDURE [dbo].[UpdateUser]
	@inUsername VARCHAR(32),
	@inNewUsername VARCHAR(32),
	@inNewPassword VARCHAR(32),
	@outResultCode INT OUTPUT,
	@outResultMessage VARCHAR(64) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @outResultCode = 0;
	SET @outResultMessage = 'Operación exitosa';

	IF NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE Username = @inUsername)
	BEGIN
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

	--Actualiza el username si se ingresó un nuevo valor
	IF (LEN(@inNewUsername) > 0)
	BEGIN
		UPDATE dbo.Usuario
			SET Username = @inNewUsername
			WHERE Username = @inUsername;
	END;
	SELECT @outResultCode AS ResultCode,
		@outResultMessage AS ResultMessage;

	SET NOCOUNT OFF;
END
GO
USE [master]
GO
ALTER DATABASE [Servicios] SET  READ_WRITE 
GO
