------------------
----- Stores -----
------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Stores')
	create sequence sunapi.SQ_Stores as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Stores' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.Stores (
		Id	bigint not null constraint PK_Stores primary key
			constraint DF_Stores_PK default(next value for sunapi.SQ_Stores),
		[Name] nvarchar(255),
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_Stores_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Stores_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Stores_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Stores_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go
-------------------------------------------------
/*
create or alter procedure sunapi.[Store.Index]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Stores!TStore!Array] = null, [Id!!Id] = Id, [Name], Memo
	from sunapi.Stores
	order by Name asc;
end
go
*/
-------------------------------------------------
create or alter procedure sunapi.[Store.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc',
@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @InitFragment nvarchar(255) = @Fragment;

	if @Fragment is not null
		set @Fragment = N'%' + upper(@Fragment) + N'%';

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	with T([Id!!Id], [Name], Memo, [!!RowNumber])
	as(
		select s.Id, s.[Name], s.Memo, [!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then s.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then s.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then s.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then s.[Name] end desc
			)
			from sunapi.Stores as s
			where (@Fragment is null or upper(s.[Name]) like @Fragment or cast(s.Id as nvarchar) like @Fragment)
	)
	select [Stores!TStore!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [!$System!] = null, 
		[!Stores!PageSize] = @PageSize, 
		[!Stores!SortOrder] = @Order, 
		[!Stores!SortDir] = @Dir,
		[!Stores!Offset] = @Offset,
		[!Stores!HasRows] = case when exists(select * from sunapi.Stores) then 1 else 0 end,
		[!Stores.Fragment!Filter] = @InitFragment
end
go
-------------------------------------------------
create or alter procedure sunapi.[Store.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Store!TStore!Object] = null, [Id!!Id] = Id, [Name], Memo
	from sunapi.Stores
	where Id=@Id;

	select [Params!TParam!Object] = null, [Text] = @Text;
end
go
-------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Store.Update')
	drop procedure sunapi.[Store.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Store.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Store.TableType];
go
------------------------------------------------
create type sunapi.[Store.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	Memo nvarchar(255)
)
go
-------------------------------------------------
create or alter procedure sunapi.[Store.Metadata]
as
begin
	set nocount on;
	declare @Store sunapi.[Store.TableType];
	select [Store!Store!Metadata] = null, * from @Store;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Store.Update]
@UserId bigint,
@Store sunapi.[Store.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.Stores as target
	using @Store as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.[Memo] = source.[Memo],
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Name], Memo, UserCreated, UserModified)
		values ([Name], Memo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	-- declare @msg nvarchar(max);
	-- select @msg = (select * from sunapi.Stores for xml auto);
	-- set @msg = concat(N'UI:', (select * from sunapi.Stores where Id=@RetId for json auto ));
	-- throw 60000, @msg, 0;

	exec sunapi.[Store.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Store.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.Stores where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Store.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [Stores!TStore!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], Memo
	from sunapi.Stores
		where (upper([Name]) like @Search or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------
create or alter procedure sunapi.[Store.List.Load]
	@UserId bigint,
	@Id bigint = 0
as
begin
	select [Stores!TStore!Array] = null, [Id!!Id] = Id, [Name], Memo
	from sunapi.Stores
	order by Name asc;
end
go
-------------------------------------------------
