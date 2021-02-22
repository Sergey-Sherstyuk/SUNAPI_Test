----------------------
----- PriceTypes -----
----------------------

-- Table declaration is in product-section-unit-price file.

-------------------------------------------------
create or alter procedure sunapi.[PriceType.Index]
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
		select p.Id, p.[Name], p.Memo, [!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then p.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then p.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then p.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then p.[Name] end desc
			)
			from sunapi.PriceTypes as p
			where (@Fragment is null or upper(p.[Name]) like @Fragment or cast(p.Id as nvarchar) like @Fragment)
	)
	select [PriceTypes!TPriceType!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [!$System!] = null, 
		[!PriceTypes!PageSize] = @PageSize, 
		[!PriceTypes!SortOrder] = @Order, 
		[!PriceTypes!SortDir] = @Dir,
		[!PriceTypes!Offset] = @Offset,
		[!PriceTypes!HasRows] = case when exists(select * from sunapi.PriceTypes) then 1 else 0 end,
		[!PriceTypes.Fragment!Filter] = @InitFragment
end
go
-------------------------------------------------
create or alter procedure sunapi.[PriceType.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [PriceType!TPriceType!Object] = null, [Id!!Id] = Id, [Name], Memo
	from sunapi.PriceTypes
	where Id=@Id;

	select [Params!TParam!Object] = null, [Text] = @Text;
end
go
-------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'PriceType.Update')
	drop procedure sunapi.[PriceType.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'PriceType.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[PriceType.TableType];
go
------------------------------------------------
create type sunapi.[PriceType.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	Memo nvarchar(255)
)
go
-------------------------------------------------
create or alter procedure sunapi.[PriceType.Metadata]
as
begin
	set nocount on;
	declare @PriceType sunapi.[PriceType.TableType];
	select [PriceType!PriceType!Metadata] = null, * from @PriceType;
end
go
-------------------------------------------------
create or alter procedure sunapi.[PriceType.Update]
@UserId bigint,
@PriceType sunapi.[PriceType.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.PriceTypes as target
	using @PriceType as source
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

	exec sunapi.[PriceType.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[PriceType.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.PriceTypes where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[PriceType.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [PriceTypes!TPriceType!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], Memo
	from sunapi.PriceTypes
		where (upper([Name]) like @Search or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------
