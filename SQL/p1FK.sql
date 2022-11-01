Use Servicios
go


ALTER TABLE dbo.Persona WITH CHECK ADD CONSTRAINT FK_Persona_TipoDocumentoIdentidad FOREIGN KEY (idTipoDocumentoIdentidad) 
REFERENCES dbo.TipoDocumentoIdentidad (id)
GO
ALTER TABLE [dbo].[Persona] CHECK CONSTRAINT FK_Persona_TipoDocumentoIdentidad
GO