----------------------
----- Operations -----
----------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Operations')
	create sequence sunapi.SQ_Operations as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Operations' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.Operations (
		Id	bigint not null constraint PK_Operations primary key
			constraint DF_Operations_PK default(next value for sunapi.SQ_Operations),
		[Name] nvarchar(255),
		Income bit not null constraint DF_Operations_Income default(1),
		Outgoing bit not null constraint DF_Operations_Outgoing default(1),
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_Operations_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Operations_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Operations_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Operations_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go
-------------------------------------------------
/*
create or alter procedure sunapi.[Operation.Index]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Operations!TOperation!Array] = null, [Id!!Id] = Id, [Name], Memo
	from sunapi.Operations
	order by Name asc;
end
go
*/
-------------------------------------------------
create or alter procedure sunapi.[Operation.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc',
@Filter nvarchar(20) = null,
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

	with T([Id!!Id], [Name], Income, Outgoing, Memo, [!!RowNumber])
	as(
		select op.Id, op.[Name], op.Income, op.Outgoing, op.Memo, [!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then op.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then op.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then op.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then op.[Name] end desc
			)
			from sunapi.Operations as op
			where (
				(@Fragment is null or upper(op.[Name]) like @Fragment or cast(op.Id as nvarchar) like @Fragment)
				and
				( (@Filter is null or (@Filter=N'Income' and op.Income = 1)) or (@Filter is null or (@Filter=N'Outgoing' and op.Outgoing = 1)) )
			)
	)
	select [Operations!TOperation!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [!$System!] = null, 
		[!Operations!PageSize] = @PageSize, 
		[!Operations!SortOrder] = @Order, 
		[!Operations!SortDir] = @Dir,
		[!Operations!Offset] = @Offset,
		[!Operations!HasRows] = case when exists(select * from sunapi.Operations) then 1 else 0 end,
		[!Operations.Fragment!Filter] = @InitFragment
end
go
-------------------------------------------------
create or alter procedure sunapi.[Operation.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Operation!TOperation!Object] = null, [Id!!Id] = Id, [Name], Income, Outgoing, Memo
	from sunapi.Operations
	where Id=@Id;

	select [Params!TParam!Object] = null, [Text] = @Text;
end
go
-------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Operation.Update')
	drop procedure sunapi.[Operation.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Operation.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Operation.TableType];
go
------------------------------------------------
create type sunapi.[Operation.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	Income bit,
	Outgoing bit,
	Memo nvarchar(255)
)
go
-------------------------------------------------
create or alter procedure sunapi.[Operation.Metadata]
as
begin
	set nocount on;
	declare @Operation sunapi.[Operation.TableType];
	select [Operation!Operation!Metadata] = null, * from @Operation;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Operation.Update]
@UserId bigint,
@Operation sunapi.[Operation.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.Operations as target
	using @Operation as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.[Income] = source.[Income],
			target.[Outgoing] = source.[Outgoing],
			target.[Memo] = source.[Memo],
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Name], Income, Outgoing, Memo, UserCreated, UserModified)
		values ([Name], Income, Outgoing, Memo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	-- declare @msg nvarchar(max);
	-- select @msg = (select * from sunapi.Operations for xml auto);
	-- set @msg = concat(N'UI:', (select * from sunapi.Operations where Id=@RetId for json auto ));
	-- throw 60000, @msg, 0;

	exec sunapi.[Operation.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Operation.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.Operations where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Operation.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [Operations!TOperation!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], Income, Outgoing, Memo
	from sunapi.Operations
		where (upper([Name]) like @Search or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------
create or alter procedure sunapi.[Operation.List.Load]
	@UserId bigint,
	@Id bigint = 0
as
begin
	select [Operations!TOperation!Array] = null, [Id!!Id] = Id, [Name], Income, Outgoing, Memo
	from sunapi.Operations
	order by Name asc;
end
go
-------------------------------------------------
