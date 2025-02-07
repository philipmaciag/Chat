
/****** Object:  StoredProcedure [dbo].[rv_deleteschema]    Script Date: 16.07.2023 20:35:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rv_deleteschema] @name sysname
as
begin
declare @sql nvarchar(max) = '
drop procedure rv_reserve_'+@name+';
drop procedure rv_rollback_'+@name+';
drop procedure rv_confirm_'+@name+';
drop table rv_'+@name+';
'
exec sp_executesql @sql;
end
GO


