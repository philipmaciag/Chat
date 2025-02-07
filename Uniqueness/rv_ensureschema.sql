USE [Test]
GO

/****** Object:  StoredProcedure [dbo].[rv_ensureschema]    Script Date: 16.07.2023 20:34:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rv_ensureschema] @name sysname 
as 
begin

declare @createTableSql nvarchar(max) = 'create table rv_'+@name+'
(Id bigint identity(1,1) primary key,
[Name] nvarchar(255) not null,
[Created] datetime not null,
[Confirmed] datetime
);

create unique nonclustered index IX_rv_'+@name+'
on rv_'+@name+'([Name]);'

declare @reserveSql nvarchar(max) = 'create procedure rv_reserve_'+@name+' @name nvarchar(255)
as 
begin

declare @lockId bigint = 0;
declare @n datetime = GetDate();
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;  

begin transaction x
	select @lockId=[Id] 
	from rv_'+@name+' 
	where [Name]=@name
	
	if (@lockId = 0) 
	begin
		insert into rv_'+@name+'([Name], [Created]) values(@name, getdate())
		set @lockId = scope_identity();
	end
commit transaction x

return @lockId;
end'

declare @rollbackSql nvarchar(max) = 'create procedure rv_rollback_'+@name+' @name nvarchar(255)
as 
begin
delete from rv_'+@name+' where [Name]=@name
end'
declare @cofirmSql nvarchar(max) = 'create procedure rv_confirm_'+@name+' @name nvarchar(255)
as
begin  

update rv_'+@name+'
set [Confirmed]=getdate()
where [Name]=@name

declare @rowAffected int = @@ROWCOUNT

end'
declare @tableName sysname = 'rv_'+@name;
if not exists (select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME =@tableName)
begin
	exec sp_executesql @createTableSql;
	exec sp_executesql @reserveSql;
	exec sp_executesql @rollbackSql;
	exec sp_executesql @cofirmSql;
end
end
GO


