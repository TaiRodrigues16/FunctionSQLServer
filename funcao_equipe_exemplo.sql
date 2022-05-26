USE [BANCO]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: <Taiane Rodrigues>
-- Description: <Retorna o nome das pessoas de uma equipe de uma ou mais pessoas em uma só string, para aparecer na view necessária>
-- =============================================
ALTER FUNCTION [dbo].[equipe_na_string]
(
@pk INT
)
RETURNS VARCHAR(2048)
AS
BEGIN
	DECLARE @equipe VARCHAR(2048)
	DECLARE @nome_equipe VARCHAR(256)

	SET @equipe = ''

	DECLARE consulta_cursor CURSOR FOR
	SELECT CAST(me.equipe AS VARCHAR(MAX)) AS equipe
	FROM mascara_equipe me
	LEFT JOIN dbo.tabela_nc nc
	ON nc.pk =  me.pk_nc
	WHERE me.pk_nc = @pk

	OPEN consulta_cursor
	
	--CURSOR FUNCIONANDO VAI ACRESCENTANDO OS NOMES NA STRING APÓS A CONSULTA
	FETCH NEXT FROM consulta_cursor
	INTO @nome_equipe
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	SET @equipe += @nome_equipe + ', '

	FETCH NEXT FROM consulta_cursor
	INTO @nome_equipe
	END

	CLOSE consulta_cursor;  
	DEALLOCATE consulta_cursor;

	--RETIRA A ÚLTIMA POSIÇÃO DA STRING ELIMINANDO A VÍRGULA
	IF(LEN(@equipe) > 0)
	BEGIN
	SET @equipe = SUBSTRING(@equipe, 1, LEN(@equipe)-1)
	END
	ELSE
	BEGIN
	SET @equipe = NULL
	END

	RETURN @equipe

END  


--EXEMPLO FUNCIONANDO EM UM SELECT
SELECT DISTINCT tt.pk, equipe = dbo.equipe_naoconformidade(mnc.pk), introducao
	FROM dbo.teste tt
	LEFT JOIN dbo.mascara_equipe mnc
		ON tt.pk = mnc.pk
