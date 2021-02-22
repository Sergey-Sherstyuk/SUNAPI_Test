------------------------
----- Expenditures -----
------------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Expenditures')
	create sequence sunapi.SQ_Expenditures as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Expenditures' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.Expenditures (
		Id	bigint not null constraint PK_Expenditures primary key
			constraint DF_Expenditures_PK default(next value for sunapi.SQ_Expenditures),
		[Name] nvarchar(255),
		Income bit not null constraint DF_Expenditures_Income default(1),
		Outgoing bit not null constraint DF_Expenditures_Outgoing default(1),
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_Expenditures_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Expenditures_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Expenditures_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Expenditures_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go
-------------------------------------------------
/*
create or alter procedure sunapi.[Expenditure.Index]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Expenditures!TExpenditure!Array] = null, [Id!!Id] = Id, [Name], Memo
	from sunapi.Expenditures
	order by Name asc;
end
go
*/
-------------------------------------------------
create or alter procedure sunapi.[Expenditure.Index]
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
		select e.Id, e.[Name], e.Income, e.Outgoing, e.Memo, [!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then e.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then e.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then e.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then e.[Name] end desc
			)
			from sunapi.Expenditures as e
			where (
				(@Fragment is null or upper(e.[Name]) like @Fragment or cast(e.Id as nvarchar) like @Fragment)
				and
				( (@Filter is null or (@Filter=N'Income' and e.Income = 1)) or (@Filter is null or (@Filter=N'Outgoing' and e.Outgoing = 1)) )
			)
	)
	select [Expenditures!TExpenditure!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [!$System!] = null, 
		[!Expenditures!PageSize] = @PageSize, 
		[!Expenditures!SortOrder] = @Order, 
		[!Expenditures!SortDir] = @Dir,
		[!Expenditures!Offset] = @Offset,
		[!Expenditures!HasRows] = case when exists(select * from sunapi.Expenditures) then 1 else 0 end,
		[!Expenditures.Fragment!Filter] = @InitFragment
end
go
-------------------------------------------------
create or alter procedure sunapi.[Expenditure.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Expenditure!TExpenditure!Object] = null, [Id!!Id] = Id, [Name], Income, Outgoing, Memo
	from sunapi.Expenditures
	where Id=@Id;

	select [Params!TParam!Object] = null, [Text] = @Text;
end
go
-------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Expenditure.Update')
	drop procedure sunapi.[Expenditure.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Expenditure.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Expenditure.TableType];
go
------------------------------------------------
create type sunapi.[Expenditure.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	Income bit,
	Outgoing bit,
	Memo nvarchar(255)
)
go
-------------------------------------------------
create or alter procedure sunapi.[Expenditure.Metadata]
as
begin
	set nocount on;
	declare @Expenditure sunapi.[Expenditure.TableType];
	select [Expenditure!Expenditure!Metadata] = null, * from @Expenditure;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Expenditure.Update]
@UserId bigint,
@Expenditure sunapi.[Expenditure.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.Expenditures as target
	using @Expenditure as source
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
	-- select @msg = (select * from sunapi.Expenditures for xml auto);
	-- set @msg = concat(N'UI:', (select * from sunapi.Expenditures where Id=@RetId for json auto ));
	-- throw 60000, @msg, 0;

	exec sunapi.[Expenditure.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Expenditure.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.Expenditures where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Expenditure.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [Expenditures!TExpenditure!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], Income, Outgoing, Memo
	from sunapi.Expenditures
		where (upper([Name]) like @Search or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------
create or alter procedure sunapi.[Expenditure.List.Load]
	@UserId bigint,
	@Id bigint = 0
as
begin
	select [Expenditures!TExpenditure!Array] = null, [Id!!Id] = Id, [Name], Income, Outgoing, Memo
	from sunapi.Expenditures
	order by Name asc;
end
go
-------------------------------------------------
